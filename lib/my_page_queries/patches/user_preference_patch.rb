require_dependency 'user_preference'

module MyPageQueries::Patches::UserPreferencePatch
  extend ActiveSupport::Concern

  included do
    alias_method_chain :add_block, :query_and_text
  end
  
  def add_block_with_query_and_text(block)
    block = block.to_s.underscore
    return unless block.present? && (Redmine::MyPage.block_options(my_page_layout.values.flatten).map(&:last).include?(block) ||
                                     block =~  /\Aquery(_\d+)?\z/ ||
                                     block =~  /\Atext(_\d+)?\z/)
                                     
    remove_block(block)
    # add it to the first group
    group = my_page_groups.first
    my_page_layout[group] ||= []
    my_page_layout[group].unshift(block)
  end

end

unless UserPreference.included_modules.include?(MyPageQueries::Patches::UserPreferencePatch)
  UserPreference.send :include, MyPageQueries::Patches::UserPreferencePatch
end
