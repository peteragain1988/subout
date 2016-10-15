class Admin::TermsController < Admin::BaseController

  def index
    @terms = Term.all
  end

  def new
    @term = Term.new
  end

  def show
    @term = Term.find(params[:id])
    content = @term.pdf.read
    send_data content, type: 'application/pdf', disposition: "inline"
  end

  def create
    @term = Term.create(term_params)
    redirect_to admin_terms_path
  end

  def publish
    flash[:notice] = "Published successfully!"
    @term = Term.find(params[:id])
    @term.create_docsign_template
    redirect_to admin_terms_path
  end

  def term_params
    params.require(:term).permit(:pdf)
  end
end