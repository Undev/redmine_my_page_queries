module MyPageQueriesHelper
  def extract_query_id_from_block(block)
    $1.to_i if block =~ /\Aquery_(\d+)\z/
  end

  def query_from_block(user, block)
    query_id = extract_query_id_from_block(block)
    user.detect_query(query_id)
  end

  def text_block?(block)
    block =~ /\Atext_(\d+)\z/
  end

  def my_queries(user)
    queries = reject_used_queries(user.my_visible_queries)
    queries.empty? ? {} : { l(:label_my_queries) => grouped_queries_for_select(queries) }
  end

  def queries_from_my_projects(user)
    queries = reject_used_queries(user.queries_from_my_projects)
    queries.empty? ? {} : { l(:label_queries_from_my_projects) => grouped_queries_for_select(queries) }
  end

  def queries_from_public_projects(user)
    queries = reject_used_queries(user.queries_from_public_projects)
    queries.empty? ? {} : { l(:label_queries_from_public_projects) => grouped_queries_for_select(queries) }
  end

  def grouped_queries_for_select(queries)
    result = []

    by_project = queries.group_by { |q| q.project }
    global     = by_project.delete(nil) || []

    result     += global.map { |q| [q.name, query_string_id(q)] } if global.any?

    by_project.each do |project, queries|
      result += queries.map { |q| ["#{project.name} - #{q.name}", query_string_id(q)] }
    end

    result
  end

  def reject_used_queries(queries)
    queries.reject { |q| @user.pref.my_page_layout.values.flatten.include? query_string_id(q) }
  end

  def query_string_id(query)
    "query_#{query.id}"
  end
end
