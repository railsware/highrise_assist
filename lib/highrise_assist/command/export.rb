module HighriseAssist
  module Command
    class Export < Base

      FORMATS = %w(yaml xml)

      def initialize(*)
        super

        require_option!(:directory)
        @root_dir = File.expand_path(options[:directory])

        @format = options[:format] || FORMATS.first
        FORMATS.include?(@format) or abort "Unsupported format: #{@format}"

        @format_method = "to_#{@format}".to_sym

        @tags = []

        @parties = {}
      end

      attr_reader :root_dir, :format, :format_method

      def run
        authenticate

        log "* Fetching data ..."

        fetch_tags if options[:tag]

        %w(Person Company).each do |type|
          collection = fetch_collection(type)
          store_collection(collection)
          @parties[type] = collection
        end

        %w(Kase Deal).each do |type|
          next if options[:skip_items].include?(type)
          collection = fetch_collection(type)
          filter_casedeal_collection!(collection)
          store_collection(collection)
          symlink_casedeal_collection(collection)
        end

        log "Done."
      end

      protected

      def fetch_tags
        log "* Fetching tags ..."
        @tags = Highrise::Tag.find(:all).select { |t| t.name == options[:tag] }
        @tags.empty? and abort "Unknown tag #{options[:tag]}"
      end

      def fetch_collection(type)
        klass = Highrise.const_get(type)
        if @tags.empty?
          collection = klass.find(:all) || []
        else
          collection = []
          @tags.each do |tag|
            collection += klass.find(:all, :params => { :tag_id => tag.id } )
          end
          collection.uniq!
        end
        log ""
        log "# #{type}: Found #{collection.size} items"
        collection
      end

      # Person, Company, Kase, Deal
      def store_collection(collection)
        return if collection.empty?
        base_dir = File.join(root_dir, item_dirname(collection.first))
        FileUtils.mkdir_p(base_dir)

        size = collection.size
        collection.each_with_index do |item, index|
          log ""
          log("= #{index+1}of#{size}:")

          dir = File.join(base_dir, item_filename(item))
          FileUtils.mkdir_p(dir)

          store_item(item, dir, "  * ")
          store_item_collection(item, "Note",  :notes, dir) unless options[:skip_items].include?("Note")
          store_item_collection(item, "Email", :emails, dir) unless options[:skip_items].include?("Email")
        end
      end

      # Note, Email,
      # Note Attachments, Email Attachments, 
      # Note Comments, Email Comments,
      # Note Comment Attachments, Email Comment, Attachments
      def store_item_collection(item, type, collection_name, base_dir)
        collection = item.send(collection_name)
        log "  * Found #{collection.size} #{collection_name}"

        attachment_dir = File.join(base_dir, "attachments")
        FileUtils.mkdir_p(attachment_dir)

        collection.each_with_index do |item, index|
          attachments = item.attributes['attachments'] || []

          unless options[:skip_items].include?("Comment")
            comments = item.comments
            item.attributes['comments'] = comments
          else
            comments = []
          end

          log "    * Found #{comments.size} comments, #{attachments.size} attachments"
          store_item(item, base_dir, "    * ")

          attachments.each do |attachment|
            download_attachment(attachment, attachment_dir, "    * ")
          end

          comments.each do |comment|
            (comment.attributes['attachments'] || []).each do |attachment|
              download_attachment(attachment, attachment_dir, "    * ")
            end
          end
        end
      end

      def store_item(item, dir, log_prefix = "")
        file = "#{item_filename(item)}.#{format}"
        path = File.join(dir, file)
        log "#{log_prefix}Store #{file}"
        File.open(path, "w") { |f| f << item.send(format_method) }
      end

      def download_attachment(attachment, dir, log_prefix = "")
        return if options[:skip_attachments]

        file = "#{attachment.attributes['id']}-#{attachment.attributes['name']}"
        path = File.join(dir, file)

        log "#{log_prefix}Download attachment #{file}"
        download_file(attachment.attributes['url'], path)
      end

      def filter_casedeal_collection!(collection)
        collection.reject! do |casedeal|
          parties = casedeal_parties(casedeal)
          not parties.any? { |party| fetched_party?(party) }
        end

        log "# Filtered to #{collection.size} items"
      end

      def symlink_casedeal_collection(collection)
        collection.each do |casedeal|
          casedeal_parties(casedeal).each do |party|
            next unless fetched_party?(party)
            symlink_casedeal_to_party(casedeal, party)
          end
        end
      end

      def casedeal_parties(casedeal)
        parties = []
        parties += casedeal.parties
        parties.push(casedeal.party) if casedeal.is_a?(Highrise::Deal)
        parties.compact!
        parties.uniq!
        parties
      end

      def fetched_party?(party)
        !!@parties[party.attributes['type']].detect { |p| p.id == party.id }
      end

      def symlink_casedeal_to_party(casedeal, party)
        source_name = item_filename(casedeal)
        destination_name = item_filename(party)
        source_path = File.join('..', '..', '..', item_dirname(casedeal), source_name)
        party_dir = File.join(root_dir, item_dirname(party), item_filename(party))
        destination_dir = File.join(party_dir, item_dirname(casedeal))

        FileUtils.mkdir_p(destination_dir)
        Dir.chdir(destination_dir) do
          log "  Symlink #{source_name} to #{destination_name}"
          FileUtils.ln_s(source_path, source_name)
        end
      end

      def item_dirname(item)
        case item
        when Highrise::Party
          item_dirname(item.type_object)
        when Highrise::Person
          "persons"
        when Highrise::Company
          "companies"
        when Highrise::Kase
          "cases"
        when Highrise::Deal
          "deals"
        else
          raise "Unknown #{item.class}"
        end
      end

      def item_filename(item)
        case item
        when Highrise::Party
          "#{item.attributes['type']}-#{item.id}-#{item.name}"
        when Highrise::Person
          "Person-#{item.id}-#{item.name}"
        when Highrise::Company
          "Company-#{item.id}-#{item.name}"
        when Highrise::Kase
          "Case-#{item.id}-#{item.name}"
        when Highrise::Deal
          "Deal-#{item.id}-#{item.name}"
        when Highrise::Email
          "Email-#{item.id}-#{item.title}"
        when Highrise::Note
          "Note-#{item.id}-#{item.body}"[0,64]
        else
          raise "Unknown #{item.class}"
        end.parameterize
      end

    end
  end
end
