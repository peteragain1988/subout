module WorldExt
  module UsersHelper
    def sign_in(user)
      visit '/'

      fill_in "Email", with: user.email
      fill_in "Password", with: user.password
      click_on "Sign In"

      page.should have_content("Sign Out")

      @current_user = user
    end
  end
end

World(WorldExt::UsersHelper)
