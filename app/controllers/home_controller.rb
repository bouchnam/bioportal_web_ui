class HomeController < ApplicationController
  layout :determine_layout


  include FairScoreHelper

  def index
    @ontologies_views = LinkedData::Client::Models::Ontology.all(include_views: true)
    @ontologies = @ontologies_views.select {|o| !o.viewOf}
    @ontologies_hash = Hash[@ontologies_views.map {|o| [o.acronym, o]}]
    @groups = LinkedData::Client::Models::Group.all
    @notes = LinkedData::Client::Models::Note.all
    @last_notes = []
    unless @notes.empty?
      @notes.sort! {|a,b| b.created <=> a.created }
      @notes[0..20].each do |n|
        ont_uri = n.relatedOntology.first
        ont = LinkedData::Client::Models::Ontology.find(ont_uri)
        next if ont.nil?
        username = n.creator.split("/").last
        note = {
            :uri => n.links['ui'],
            :id => n.id,
            :subject => n.subject,
            :body => n.body,
            :created => n.created,
            :author => username,
            :ont_name => ont.name
        }
        @last_notes.push note
        break if @last_notes.length >= [$HOME_LATEST_NOTES_COUNT.to_i, 5].max
      end
    end
    # Get the latest manual mappings
    # All mapping classes are bidirectional.
    # Each class in the list maps to all other classes in the list.
    if $DISPLAY_RECENT.nil? || $DISPLAY_RECENT == true
      @recent_mappings = get_recent_mappings  # application_controller
    end
    
    organize_groups

    # Calculate BioPortal summary statistics
    @ont_count = @ontologies.length
    @cls_count = LinkedData::Client::Models::Metrics.all.map {|m| m.classes.to_i}.sum

    @individuals_count = LinkedData::Client::Models::Metrics.all.map {|m| m.individuals.to_i}.sum
    if $RESOURCE_INDEX_DISABLED == false
      begin
        @resources = LinkedData::Client::ResourceIndex.resources # application_controller
        @ri_resources = @resources.length
        @ri_record_count = @resources.map {|r| r.count}.sum
      rescue
        @resources = []
        @ri_resources = 0
        @ri_record_count = 0
      end
      @ri_stats = LinkedData::Client::ResourceIndex.annotation_counts
      @direct_annotations = @ri_stats[:total][:direct]
      @direct_expanded_annotations = @ri_stats[:total][:ancestors]
    end

    @prop_count = 36286
    @map_count = total_mapping_count
    @analytics = LinkedData::Client::Analytics.last_month

    @ontology_names = @ontologies.map{ |ont| ["#{ont.name} (#{ont.acronym})", ont.acronym] }

    @anal_ont_names = {}
    @anal_ont_numbers = []
    @analytics.onts[0..4].each do |visits|
      ont = @ontologies_hash[visits[:ont].to_s]
      @anal_ont_names[ont.acronym] = ont.name
      @anal_ont_numbers << visits[:views]
    end


  end

  def render_layout_partial
    partial = params[:partial]
    render partial: "layouts/#{partial}"
  end

  def release
    redirect_to :controller => 'home', :action => 'help'
  end

  def help
    # Show the header/footer or not
    layout = params[:pop].eql?("true") ? "popup" : "ontology"
    render :layout => layout
  end

  def recommender

  end

  def annotate

  end

  def all_resources
    @conceptid = params[:conceptid]
    @ontologyid = params[:ontologyid]
    @ontologyversionid = params[:ontologyversionid]
    @search = params[:search]
  end

  def feedback
    # Show the header/footer or not
    feedback_layout = params[:pop].eql?("true") ? "popup" : "ontology"

    # We're using a hidden form field to trigger for error checking
    # If sim_submit is nil, we know the form hasn't been submitted and we should
    # bypass form processing.
    if params[:sim_submit].nil?
      render :layout => feedback_layout
      return
    end

    @errors = []

    if params[:name].nil? || params[:name].empty?
      @errors << "Please include your name"
    end
    if params[:email].nil? || params[:email].length <1 || !params[:email].match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      @errors << "Please include your email"
    end
    if params[:comment].nil? || params[:comment].empty?
      @errors << "Please include your comment"
    end
    if using_captcha? && !session[:user]
      if !verify_recaptcha
        @errors << "Please fill in the proper text from the supplied image"
      end
    end

    unless @errors.empty?
      render layout: feedback_layout
      return
    end

    Notifier.feedback(params[:name],params[:email],params[:comment],params[:location]).deliver_now

    if params[:pop].eql?("true")
      render "feedback_complete", layout: "popup"
    else
      flash[:notice]="Feedback has been sent"
      redirect_to_home
    end
  end

  def user_intention_survey
    render :partial => "user_intention_survey", :layout => false
  end

  def site_config
    render json: bp_config_json
  end

  def account
    @title = "Account Information"
    if session[:user].nil?
      redirect_to :controller => 'login', :action => 'index', :redirect => "/account"
      return
    end

    @user = LinkedData::Client::Models::User.get(session[:user].id, include: "all")

    @user_ontologies = @user.customOntology
    @user_ontologies ||= []

    onts = LinkedData::Client::Models::Ontology.all;
    @admin_ontologies = onts.select {|o| o.administeredBy.include? @user.id }

    projects = LinkedData::Client::Models::Project.all;
    @user_projects = projects.select {|p| p.creator.include? @user.id }

    render "users/show"
  end

  def feedback_complete
  end

  def validate_ontology_file_show
  end

  def validate_ontology_file
    response = LinkedData::Client::HTTP.post("/validate_ontology_file", ontology_file: params[:ontology_file])
    @process_id = response.process_id
  end

  private

  # Dr. Musen wants 5 specific groups to appear first, sorted by order of importance.
  # Ordering is documented in GitHub: https://github.com/ncbo/bioportal_web_ui/issues/15.
  # All other groups come after, with agriculture in the last position.
  def organize_groups
    # Reference: https://lildude.co.uk/sort-an-array-of-strings-by-severity
    acronyms = ["UMLS", "OBO_Foundry", "WHO-FIC", "CTSA", "caBIG"]
    size = @groups.size
    @groups.sort_by! { |g| acronyms.find_index(g.acronym[/(UMLS|OBO_Foundry|WHO-FIC|CTSA|caBIG)/]) || size }

    others, agriculture = @groups.partition { |g| g.acronym != "CGIAR" }
    @groups = others + agriculture
  end

end
