module ItemsHelper
  def span_for(record, *args, &block)
    content_tag_for(:span, record, *args, &block)
  end
end