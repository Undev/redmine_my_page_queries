class QueryPresenter < SimpleDelegator

  DEFAULT_LIMIT = 10

  include SortHelper

  def initialize(obj, view_context)
    super(obj)
    @view = view_context
  end

  def title
    if project.nil?
      "#{name} (#{issue_count})"
    else
      "#{project.name} - #{name} (#{issue_count})"
    end
  end

  def link(title)
    url_opts              = { controller: 'issues',
                              action:     'index',
                              query_id:   self[:id] }

    url_opts[:project_id] = project.id unless project.nil?
    @view.link_to title, url_opts
  end

  def issues(options = {})
    options.merge!(
      limit:   limit,
      order:   sort_criteria.sort_clause(sortable_columns)
    )
    super(options)
  end

  def limit
    optn = pref_options[:limit]
    optn && optn.to_i || DEFAULT_LIMIT
  end

  def pagination_links
    [
      link(@view.l(:label_issue_view_all)),
      limit_links,
      view_format_links
    ].join(' | ').html_safe
  end

  def compact_view?
    pref_options[:compact_view].nil? || pref_options[:compact_view] == 'true'
  end

  def sort_criteria
    @sort_criteria ||= begin
      criteria = Redmine::SortCriteria.new(pref_options[:sort])
      criteria
    end
  end

  def column_header(query, column, options={})
    if column.sortable?
      css, order = nil, column.default_order
      if column.name.to_s == query.sort_criteria.first_key
        if query.sort_criteria.first_asc?
          css = 'sort asc'
          order = 'desc'
        else
          css = 'sort desc'
          order = 'asc'
        end
      end
      param_key = options[:sort_param] || :sort
      sort_param = { param_key => query.sort_criteria.add(column.name, order).to_param }
      while sort_param.keys.first.to_s =~ /^(.+)\[(.+)\]$/
        sort_param = {$1 => {$2 => sort_param.values.first}}
      end             
      url_options = @view.update_query_block_path(self[:id], query: sort_param)
      content = @view.link_to(column.caption,
                              url_options,
                              method: 'put',
                              remote: true,
                              class:  css)
    else
      content = column.caption
    end
    @view.content_tag('th', content)
  end

  private

  def sort_header_tag(column, options = {})
    caption         = options.delete(:caption) || column.to_s.humanize
    default_order   = options.delete(:default_order) || 'asc'
    options[:title] = l(:label_sort_by, "\"#{caption}\"") unless options[:title]
    @view.content_tag('th', sort_link(column, caption, default_order), options)
  end

  def sort_link(column, caption, default_order)
    css, order = nil, default_order

    if column.to_s == sort_criteria.first_key
      if sort_criteria.first_asc?
        css   = 'sort asc'
        order = 'desc'
      else
        css   = 'sort desc'
        order = 'asc'
      end
    end
    caption = column.to_s.humanize unless caption

    sort_options = { sort: sort_criteria.add(column.to_s, order).to_param }

    url_options = @view.update_query_block_path(self[:id], query: sort_options)

    @view.link_to caption,
                  url_options,
                  method: 'put',
                  remote: true,
                  class:  css
  end

  def available_limits
    (Setting.per_page_options_array + [1, 3, 5, 10]).sort.uniq
  end

  def limit_links
    limits = available_limits.map do |q_limit|
      @view.link_to q_limit,
                    @view.update_query_block_path(self[:id], query: { limit: q_limit }),
                    method: 'put',
                    remote: true
    end.join(', ').html_safe
    @view.l(:my_page_query_limit, limits: limits).html_safe
  end

  def view_format_links
    links = []
    if compact_view?
      links << @view.l(:my_page_query_compact)
      links << @view.link_to(@view.l(:my_page_query_full),
                             @view.update_query_block_path(
                               self[:id],
                               query: { compact_view: false }),
                             method: 'put',
                             remote: true)
    else
      links << @view.link_to(l(:my_page_query_compact),
                             @view.update_query_block_path(
                               self[:id],
                               query: { compact_view: true }),
                             method: 'put',
                             remote: true)
      links << @view.l(:my_page_query_full)
    end
    links.join('/').html_safe
  end

  def pref_options
    User.current.pref.others[pref_key] || {}
  end

  def pref_key
    "query_#{self[:id]}".to_sym
  end

end
