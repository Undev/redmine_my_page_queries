require_dependency 'my_helper'

module MyPageQueries::Patches::MyHelperPatch
  extend ActiveSupport::Concern
  
  included do
    alias_method_chain :render_block_content, :query_and_text
    alias_method_chain :block_select_tag,     :query_and_text
  end

  def render_block_content_with_query_and_text(block, user)
    if (query = query_from_block(user, block))
      query_presenter = QueryPresenter.new(query, self)
      render 'my/query_block',
             user:  user,
             query: query_presenter
    elsif text_block?(block)
      render 'my/text_block',
             user:       user,
             block_name: block,
             text:       user.my_page_text_block(block) || l(:label_text)
    else
      render_block_content_without_query_and_text(block, user)
    end
  end
  
  def block_select_tag_with_query_and_text(user)
    blocks_in_use = user.pref.my_page_layout.values.flatten
    options = []
    Redmine::MyPage.block_options(blocks_in_use).each do |label, block|
      options << [label, block] unless block.blank?
    end
    my_page_blocks  = grouped_options_for_select(l(:label_my_page) => options + [[l(:field_text), "#{MyPageQueries::Patches::MyHelperPatch.detect_new_text_block}"]])
    my_query_blocks = grouped_options_for_select(my_queries(user)) +
                      grouped_options_for_select(queries_from_my_projects(user)) +
                      grouped_options_for_select(queries_from_public_projects(user))
    select_tag('block', content_tag('option') + my_page_blocks + my_query_blocks, :id => "block-select", :onchange => "$('#block-form').submit();")
  end
  
  def self.detect_new_text_block(user = User.current)
    layout   = user.pref[:my_page_layout] || {}
    block_id = 1
    while true
      block = "#{MyPageQueries::TEXT_BLOCK}_#{block_id}"
      return block unless %w(top left right).detect { |f| (layout[f] ||= []).include?(block) }
      block_id += 1
    end
  end
end

unless MyHelper.included_modules.include?(MyPageQueries::Patches::MyHelperPatch)
  MyHelper.send :include, MyPageQueries::Patches::MyHelperPatch
end
