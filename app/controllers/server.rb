module TrafficSpy

  class Server < Sinatra::Base

    helpers do
      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['hello1', 'hello4']
      end
    end

    get '/' do
      erb :index
    end

    post "/sources" do
     source_params = {}
     source_params[:root_url]    = params[:rootUrl]
     source_params[:identifier  ]  = params[:identifier]

     source = Source.new(source_params)

      if source.save
        body "{identifier: #{params[:identifier]}}"
      else
        message = source.errors.messages.to_a.flatten
        registrator = SourceRegistrator.new(message)
        status registrator.error_status
        body registrator.error_message
      end
    end

    post "/sources/:identifier/data" do |identifier|
      if params['payload'] == nil
        status 400
        body 'Bad Request - Needs a payload'
        break
      end

      source = Source.find_by_identifier(identifier)
      validator = PayloadValidator.new(params['payload'], source)
      digest = validator.create_digest
      payload_params = validator.json_parser
      browser = validator.browser_parser(payload_params['userAgent'])
      operating_system = validator.os_parser(payload_params['userAgent'])


      if Payload.new(digest: digest).valid?
        url = Url.find_or_create_by(url: payload_params['url'])
        response = Response.find_or_create_by(
                     requested_at: payload_params['requestedAt'],
                     responded_in: payload_params['respondedIn'],
                     ip: payload_params['ip'],
                     request_type: payload_params['requestType'])

        browser = Browser.find_or_create_by(browser: browser, operating_system:
        operating_system)
        resolution = Resolution.find_or_create_by(
                        resolution_width: payload_params['resolutionWidth'],
                        resolution_height: payload_params['resolutionHeight'])
        referrer = Referrer.find_or_create_by(referred_by: payload_params['referredBy'])
        event = Event.find_or_create_by(event_name: payload_params['eventName'])

        unless source.nil?
            payload = Payload.new(digest: digest,
                                  source_id: source.id,
                                  url_id: url.id,
                                  resolution_id: resolution.id,
                                  browser_id: browser.id,
                                  response_id: response.id,
                                  referrer_id: referrer.id,
                                  event_id: event.id)

        if payload.save
          status 200
          body "OK"
        end
        else
          status 403
          body 'Forbidden - Must have registered identifier'
        end
      else
        status 403
        body 'Forbidden - Must be unique payload'
      end
    end

    get '/sources/:identifier' do |identifier|
      protected!
      @source             = Source.find_by_identifier(identifier)
      @slugs              = Url.new.most_requested(@source)
      @average_responses  = Response.new.average_response_time(@source)
      @browser_counts     = Browser.new.list_browsers(@source)
      @os_counts          = Browser.new.list_operating_systems(@source)
      @resolutions        = Resolution.new.resolution_size(@source)
      @paths              = Url.new.path_parser(@source)
      @average_response_times = Response.new.average_response_times(@source)

      erb :show
    end

    get '/sources/:identifier/urls/:path' do |identifier, path|
      @source                   = Source.find_by_identifier(identifier)
      @paths                    = Url.new.path_parser(@source)
      @full_path                = Url.new.full_path(@source, path)
      @url                      = Url.find_by(url: @full_path)
      @path                     = path
      @requests                 = Response.new.http_verbs(@url)
      @longest_response_time    = Response.new.longest_response_time(@url)
      @shortest_response_time   = Response.new.shortest_response_time(@url)
      @average_response_time    = Response.new.average_response_time(@url)
      @most_popular_referrers   = Referrer.new.most_popular_referrers(@url)
      @most_popular_browsers    = Browser.new.most_popular_browsers(@url)
      @most_popular_os          = Browser.new.most_popular_operating_systems(@url)

      if @paths.include?("/" + path)
        status 200
        body 'OK'
        erb :"urls/show"
      else
        status 404
        body 'URL not found'
        not_found
      end
    end

    get '/sources/:identifier/events' do |identifier|
      @source               = Source.find_by_identifier(identifier)
      @events               = @source.events
      @most_received_events = Event.new.most_received_events(@source)

      if @events.empty?
        status 404
        not_found
      else
        status 200
        erb :event_index
      end
    end

    get '/sources/:identifier/events/:event' do |identifier, event|
      @source = Source.find_by(identifier: identifier)
      @event = Event.find_by(event_name: event)
      @visits = @event.payloads.count
      @visits_per_hour = Event.new.visits_per_hour(@event)
      @event_name = Event.new.make_new_words(@event.event_name).join(" ")

      if @event
        status 200
        erb :"events/show"
      else
        status 400
        not_found
      end
    end

    post '/sources/:identifier/campaigns' do |identifier|
      Source.find_by(identifier: identifier)
      campaign_name = params.fetch("campaignName", nil)
      event_names = params.fetch("eventNames", [])

      if event_names.empty? || campaign_name.nil?
        status 400
        body "Missing some params"
      elsif Campaign.exists?(name: campaign_name.strip)
        status 403
        body "Campaign already exists"
      else
        @campaign = Campaign.new(name: campaign_name.strip)
        if @campaign.save
          status 200
          @events = event_names.map { |name| Event.find_by(event_name: name.strip) }
          @campaign = Campaign.find_by(name: campaign_name.strip)

          # @events.each do |event|
            # @campaign.events << event
          # end
        end
      end
    end

    not_found do
      erb :error
    end
  end
end
