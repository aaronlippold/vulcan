# frozen_string_literal: true

##
# Controller for managing members of a specific project.
#
class MembershipsController < ApplicationController
  before_action :set_membership, only: %i[update destroy]
  before_action :authorize_admin_membership, only: %i[update destroy]

  def create
    # Ensure the current_user has permissions on the Project or component
    current_user_effective_role = if current_user.admin
                                    'admin'
                                  else
                                    Membership.where(
                                      membership_type: membership_create_params[:membership_type],
                                      membership_id: membership_create_params[:membership_id],
                                      user_id: current_user.id
                                    ).pick(:role)
                                  end
    unless current_user_effective_role == 'admin'
      raise(
        NotAuthorizedError,
        "You are not authorized to manage permissions on this #{membership_create_params[:membership_type]}"
      )
    end

    membership = Membership.new(membership_create_params)
    if membership.save
      flash.notice = 'Successfully created membership.'
      send_smtp_notification(UserMailer, 'welcome_user', current_user, membership) if Settings.smtp.enabled
      case membership.membership_type
      when 'Project'
        send_membership_notification(:create_project_membership, membership)
      when 'Component'
        send_membership_notification(:create_component_membership, membership)
      end
      redirect_to membership.membership
    else
      flash.alert = "Unable to create membership. #{membership.errors.full_messages}"
      redirect_back(fallback_location: root_path)
    end
  end

  def update
    if @membership.update(membership_update_params)
      flash.notice = 'Successfully updated membership.'
      case @membership.membership_type
      when 'Project'
        send_membership_notification(:update_project_membership, @membership)
      when 'Component'
        send_membership_notification(:update_component_membership, @membership)
      end
    else
      flash.alert = "Unable to updated membership. #{@membership.errors.full_messages}"
    end
    redirect_to @membership.membership
  end

  def destroy
    if @membership.destroy
      flash.notice = 'Successfully removed membership.'
      case @membership.membership_type
      when 'Project'
        send_membership_notification(:remove_project_membership, @membership)
      when 'Component'
        send_membership_notification(:remove_component_membership, @membership)
      end
    else
      flash.alert = "Unable to remove membership. #{@membership.errors.full_messages}"
    end
    redirect_to @membership.membership
  end

  private

  def set_membership
    @membership = Membership.find(params[:id])
  end

  # This isn't in the application controller because it is specific to the membership controller
  def authorize_admin_membership
    effective_permissions = current_user.effective_permissions(@membership.membership)

    # Break early if the user is an admin
    return if effective_permissions == 'admin'

    raise(
      NotAuthorizedError,
      "You are not authorized to manage permissions on this #{@membership.membership_type}"
    )
  end

  def membership_create_params
    params.require(:membership).permit(:user_id, :role, :membership_id, :membership_type)
  end

  def membership_update_params
    params.require(:membership).permit(:role)
  end

  def send_membership_notification(notification_type, membership)
    return unless Settings.slack.enabled

    send_slack_notification(notification_type, membership)
  end
end
