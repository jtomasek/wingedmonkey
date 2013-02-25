require 'spec_helper'

describe ProviderApplicationsController do

  describe "when not logged in" do
    describe "GET 'index'" do
      it "redirects to login" do
        get 'index'
        response.should redirect_to(login_path)
      end
    end

    describe "GET 'new'" do
      it "redirects to login" do
        get 'new'
        response.should redirect_to(login_path)
      end
    end
  end

  describe "when logged into mock provider" do
    describe "GET 'index'" do
      it "responds with success" do
        as_user mock_user do
          get 'index'
          response.should be_success
        end
      end
    end

    describe "GET 'new'" do
      it "redirects to select launchable when no launchable_id" do
        as_user mock_user do
          get 'new'
          response.should redirect_to(launchables_path)
        end
      end

      it "responds with success when launchable_id provided" do
        as_user mock_user do
          get 'new', {:launchable_id => 1}
          response.should be_success
        end
      end
    end

    describe "POST 'create'" do
      it "responds with success when there are no errors" do
        as_user mock_user do
          post "create", :launchable_id => "1", :provider_application => {:name => "New application"}
          app = ProviderApplication.all.last
          response.should redirect_to(launch_summary_provider_application_path(app.id))
        end
      end

      it "renders 'new' when parameters are missing" do
        as_user mock_user do
          post "create", :provider_application => {}
          response.should render_template("new")
        end
      end
    end

    describe "POST 'pause/start/stop' as json" do

      it "responds with status 200" do
        as_user mock_user do
          launchable = stub_model(Launchable, :id => "1")
          params = {:launchable => launchable, :name => "New application"}
          application = Providers::Mock::MockProviderApplication.new(params)
          application.save
          post "pause", {:id => application.id, :format => :json }
          response.should render_template("provider_applications/default/provider_application")
          response.status.should eql(200)
          post "start", {:id => application.id, :format => :json }
          response.should render_template("provider_applications/default/provider_application")
          response.status.should eql(200)
          post "stop", {:id => application.id, :format => :json }
          response.should render_template("provider_applications/default/provider_application")
          response.status.should eql(200)
        end
      end
    end

    describe "POST 'destroy' as json" do

      it "responds with status 200" do
        as_user mock_user do
          launchable = stub_model(Launchable, :id => "1")
          params = {:launchable => launchable, :name => "New application"}
          application = Providers::Mock::MockProviderApplication.new(params)
          application.save
          delete "destroy", {:id => application.id, :format => :json }
          response.should render_template("provider_applications/default/provider_application")
          response.status.should eql(200)
        end
      end
    end
  end
end
