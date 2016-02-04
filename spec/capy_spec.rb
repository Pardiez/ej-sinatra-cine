require 'capybara/rspec'

require './app'
Capybara.app = Sinatra::Application

describe "the signin process", :type => :feature do
  before :each do
  end

  it "signs me in" do
    visit '/'
    expect(page).to have_content 'Adquirir'
  end
end

describe "buy ticket", :type => :feature do
  it "is accesible" do
    visit '/'
    click_link 'Adquirir entrada'

    expect(page).to have_css("input", :count => 4)
    expect(page).to have_css("select", :count => 1)
  end

  it "is submitable" do
    visit '/buy'
    fill_in 'name', :with => 'David'
    fill_in 'phone', :with => '987654321'
    fill_in 'email', :with => 'davidaceimar@gmail.com'
    select "Star Wars (2.0 €)", :from => "film"
  end
end
