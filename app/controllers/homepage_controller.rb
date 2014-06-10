class HomepageController < ApplicationController
  def index
    # Pull prismic articles
    @documents = prismic_api.form('homepage').submit(prismic_ref)

    # Pull carousel images
    @carousels = prismic_api.form('everything').query('[[:d = any(document.type, ["carousel-image"])]]').orderings('[my.carousel-image.order]').submit(prismic_ref)
  end

  def prismic
    @document = get_prismic_doc_by_id(params[:prismic_id])
    status = slug_checker(@document, params[:prismic_slug])

    unless status[:correct]
      not_found unless status[:redirect]
      redirect_to prismic_document_path(@document.id, @document.slug), status: :moved_permanently
    end
  end

  private

  def get_prismic_doc_by_id(prismic_id)
    results = prismic_api.form('everything').query("[[:d = at(document.id, \"#{prismic_id}\")]]").submit(prismic_ref)

    results.length == 0 ? nil : results.first
  end

  def slug_checker(document, slug)
    if document.nil?
      return { correct: false, redirect: false }
    elsif slug == document.slug
      return { correct: true }
    elsif document.slugs.include?(slug)
      return { correct: false, redirect: true }
    else
      return { correct: false, redirect: false }
    end
  end
end
