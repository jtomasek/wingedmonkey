class ProviderApplicationsController < ApplicationController
  def index
    @provider_applications = ProviderApplication.all

    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    if params[:launchable_id].present?
      @launchable = Launchable.find(params[:launchable_id])
      @provider_application = ProviderApplication.create({:launchable_id => @launchable.id})
    else
      redirect_to launchables_path, :alert => _("Please select Application Blueprint first")
    end
  end

  def create
    @provider_application = ProviderApplication.create(params[:provider_application])
    if @provider_application.save
      redirect_to launch_summary_provider_application_path(@provider_application.id)
    else
      @launchable = Launchable.find(params[:provider_application][:launchable_id])
      render :new
    end
  end

  def show
    @provider_application = ProviderApplication.find(params[:id])
  end

  def launch_summary
    @provider_application = ProviderApplication.find(params[:id])
  end

  def destroy
    @provider_application = params[:id] ? ProviderApplication.find(params[:id]) : nil
    if !@provider_application.nil?
      @provider_application.destroy
    end

    redirect_to provider_applications_path
  end
end
