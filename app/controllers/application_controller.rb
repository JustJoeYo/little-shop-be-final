class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid do |e|
    render_error_response("Your query could not be completed", [e.message], :unprocessable_entity)
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render_error_response("Your query could not be completed", [e.message], :not_found)
  end

  def render_error_response(message, errors, status)
    render json: {
      message: message,
      errors: errors
    }, status: status
  end

  def render_validation_error(errors)
    render_error_response("Your query could not be completed", errors, :unprocessable_entity)
  end
  
  def render_not_found(resource_name, id)
    render_error_response(
      "Your query could not be completed", 
      ["Couldn't find #{resource_name} with 'id'=#{id}"], 
      :not_found
    )
  end
  
  def render_rule_error(error_message)
    render_error_response(
      "Your query could not be completed", 
      [error_message], 
      :unprocessable_entity
    )
  end

  def render_error
    render json: ErrorSerializer.format_invalid_search_response,
        status: :bad_request
  end
end