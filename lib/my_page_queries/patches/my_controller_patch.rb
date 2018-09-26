require_dependency 'query'
require_dependency 'issue_query'

module MyPageQueries::Patches::MyControllerPatch
  extend ActiveSupport::Concern

  included do
    before_filter :my_page_sort_init

    helper :sort
    include SortHelper
    helper :queries
    include QueriesHelper

    helper :my_page_queries
    include MyPageQueriesHelper

    helper_method :per_page_option
  end

  def update_query_block
    @user = User.current
    query = @user.detect_query params[:query_id]
    if query
      @block_name = "query_#{query.id}"
      update_user_query_pref_from_param(@user)
      render 'query_block', layout: false
    else
      render_404
    end
  end

  def update_text_block
    @user      = User.current
    text       = params[:my_page_text_area]
    block_name = params[:block_name]
    @user.update_my_page_text_block(block_name, text)
    render 'update_text',
           layout:       false,
           content_type: 'text/javascript',
           locals:       {
             block_name: block_name,
             text:       text
           }
  end

  private

  def my_page_sort_init
    sort_init('none')
    sort_update(['none'])
  end

  def update_user_query_pref_from_param(user)
    return unless params[:query]
    query_key = "query_#{params[:query_id]}".to_sym
    opts      = user.pref[query_key] || {}
    opts.merge! params[:query].symbolize_keys
    user.pref[query_key] = opts
    user.pref.save!
  end
end

unless MyController.included_modules.include?(MyPageQueries::Patches::MyControllerPatch)
  MyController.send :include, MyPageQueries::Patches::MyControllerPatch
end
