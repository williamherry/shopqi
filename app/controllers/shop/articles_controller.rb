#encoding: utf-8
class Shop::ArticlesController < Shop::AppController
  expose(:shop) { Shop.at(request.host) }
  expose(:blog){ shop.blogs.handle!(params[:handle]) }
  expose(:articles){ blog.articles }
  expose(:article){ Article.show(params[:article_id] || params[:id])}

  def show
    BlogsDrop
    posted_successfully = article.comments.find_by_id(params[:comment_id]).nil?
    assign = template_assign('template' => 'article', 'article' => ArticleDrop.new(article), 'blog' => BlogDrop.new(blog)).merge('posted_successfully' => !posted_successfully)
    html = Liquid::Template.parse(layout_content).render(shop_assign(assign))
    render text: html
  end

  def add_comment
    comment = article.comments.build params[:comment]
    comment.status = (article.blog.commentable == 'moderate') ? 'unapproved' : 'published'
    if comment.save
      redirect_to "/blogs/#{article.blog.handle}/#{article.id}?comment_id=#{comment.id}#comments"
    else
      BlogsDrop
      assign = template_assign('template' => 'article', 'article' => ArticleDrop.new(article), 'blog' => BlogDrop.new(blog), 'comment' => CommentDrop.new(comment))
      html = Liquid::Template.parse(layout_content).render(shop_assign(assign))
      render text: html
    end
  end
end
