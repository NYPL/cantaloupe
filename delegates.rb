require 'java'
require 'json'
##
# Sample Ruby delegate script containing stubs and documentation for all
# available delegate methods. See the "Delegate Script" section of the user
# manual for more information.
#
# The application will create an instance of this class early in the request
# cycle and dispose of it at the end of the request cycle. Instances don't need
# to be thread-safe, but sharing information across instances (requests)
# **does** need to be thread-safe.
#
# This version of the script works with Cantaloupe version 4, and not earlier
# versions. Likewise, earlier versions of the script are not compatible with
# Cantaloupe 4.
#
require './secrets'
# require 'net/http'

class CustomDelegate
  ##
  # Attribute for the request context, which is a hash containing information
  # about the current request.
  #
  # This attribute will be set by the server before any other methods are
  # called. Methods can access its keys like:
  #
  # ```
  # identifier = context['identifier']
  # ```
  #
  # The hash will contain the following keys in response to all requests:
  #
  # * `client_ip`       [String] Client IP address.
  # * `cookies`         [Hash<String,String>] Hash of cookie name-value pairs.
  # * `identifier`      [String] Image identifier.
  # * `request_headers` [Hash<String,String>] Hash of header name-value pairs.
  # * `request_uri`     [String] Public request URI.
  #
  # It will contain the following additional string keys in response to image
  # requests:
  #
  # * `full_size`      [Hash<String,Integer>] Hash with `width` and `height`
  #                    keys corresponding to the pixel dimensions of the
  #                    source image.
  # * `operations`     [Array<Hash<String,Object>>] Array of operations in
  #                    order of application. Only operations that are not
  #                    no-ops will be included. Every hash contains a `class`
  #                    key corresponding to the operation class name, which
  #                    will be one of the `e.i.l.c.operation.Operation`
  #                    implementations.
  # * `output_format`  [String] Output format media (MIME) type.
  # * `resulting_size` [Hash<String,Integer>] Hash with `width` and `height`
  #                    keys corresponding to the pixel dimensions of the
  #                    resulting image after all operations have been applied.
  #
  # @return [Hash] Request context.
  #
  attr_accessor :context

  ##
  # Deserializes the given meta-identifier string into a hash of its component
  # parts.
  #
  # This method is used only when the `meta_identifier.transformer`
  # configuration key is set to `DelegateMetaIdentifierTransformer`.
  #
  # The hash contains the following keys:
  #
  # * `identifier`       [String] Required.
  # * `page_number`      [Integer] Optional.
  # * `scale_constraint` [Array<Integer>] Two-element array with scale
  #                      constraint numerator at position 0 and denominator at
  #                      position 1. Optional.
  #
  # @param meta_identifier [String]
  # @return Hash<String,Object> See above. The return value should be
  #                             compatible with the argument to
  #                             {serialize_meta_identifier}.
  #
  def deserialize_meta_identifier(meta_identifier)
  end

    ##
  # Serializes the given meta-identifier hash.
  #
  # This method is used only when the `meta_identifier.transformer`
  # configuration key is set to `DelegateMetaIdentifierTransformer`.
  #
  # See {deserialize_meta_identifier} for a description of the hash structure.
  #
  # @param components [Hash<String,Object>]
  # @return [String] Serialized meta-identifier compatible with the argument to
  #                  {deserialize_meta_identifier}.
  #
  def serialize_meta_identifier(components)
  end

    ##
  # Returns authorization status for the current request. This method is called
  # upon all requests to all public endpoints early in the request cycle,
  # before the image has been accessed. This means that some context keys (like
  # `full_size`) will not be available yet.
  #
  # This method should implement all possible authorization logic except that
  # which requires any of the context keys that aren't yet available. This will
  # ensure efficient authorization failures.
  #
  # Implementations should assume that the underlying resource is available,
  # and not try to check for it.
  #
  # Possible return values:
  #
  # 1. Boolean true/false, indicating whether the request is fully authorized
  #    or not. If false, the client will receive a 403 Forbidden response.
  # 2. Hash with a `status_code` key.
  #     a. If it corresponds to an integer from 200-299, the request is
  #        authorized.
  #     b. If it corresponds to an integer from 300-399:
  #         i. If the hash also contains a `location` key corresponding to a
  #            URI string, the request will be redirected to that URI using
  #            that code.
  #         ii. If the hash also contains `scale_numerator` and
  #            `scale_denominator` keys, the request will be
  #            redirected using that code to a virtual reduced-scale version of
  #            the source image.
  #     c. If it corresponds to 401, the hash must include a `challenge` key
  #        corresponding to a WWW-Authenticate header value.
  #
  # @param options [Hash] Empty hash.
  # @return [Boolean,Hash<String,Object>] See above.
  #
  def pre_authorize(options = {})
    true
  end

  ##
  # Tells the server whether to redirect in response to the request. Will be
  # called upon all image requests.
  #
  # @param options [Hash] Empty hash.
  # @return [Hash<String,Object>,nil] Hash with `location` and `status_code`
  #         keys. `location` must be a URI string; `status_code` must be an
  #         integer from 300 to 399. Return nil for no redirect.
  #
  def redirect(options = {})
  end

  ##
  # Tells the server whether the given request is authorized. Will be called
  # upon all image requests to any endpoint.
  #
  # Implementations should assume that the underlying resource is available,
  # and not try to check for it.
  #
  # @param options [Hash] Empty hash.
  # @return [Boolean,Hash<String,Object>] See above.
  #
  def authorize(options = {})
    # full_res_file_access = ['10.128.99.55','10.128.1.167','10.224.6.10','10.128.99.167','10.128.98.50','10.224.6.26','10.224.6.35','172.16.1.94', '66.234.38.35']
    #'65.88.88.115'
    # logger = Java::edu.illinois.library.cantaloupe.delegate.Logger
    # logger.debug("CONTEXT HASH: #{context}")
    # logger.debug("REQUEST URI: #{context['request_uri']}")
    if context['request_uri'].include?("info.json") 
      true
    else 
      type = is_region?()? "full_res" : derivative_type(context['resulting_size'])
      # logger.debug("TYPE: #{type}")
      rights = get_rights(context['identifier'], context['client_ip'])
      allowed = returns_rights?(rights) && is_not_restricted?(rights, type)
      # logger.debug("ALLOWED? #{allowed}")
      allowed
    end
  end

  def is_region?()
    region = context['request_uri'].split('/')[6]
    (region == "full" || region == "square") ? false : true 
  end

  def derivative_type(size)
    longest_side = size["width"] > size["height"] ? size["width"] : size["height"]
    case
      when (longest_side <= 100)
        "b"
      when (longest_side > 100 && longest_side <= 140)
        "f"
      when (longest_side > 140 && longest_side <= 150)
        "t"
      when (longest_side > 150 && longest_side <= 300)
        "r"
      when (longest_side > 300 && longest_side <= 760)
        "w"
      when (longest_side > 760 && longest_side <= 1600)
        "q"
      when (longest_side > 1600 && longest_side <= 2560)
        "v"
      else
        "full_res"
    end
  end
  
  def returns_rights?(rights)
    if rights.include?("nyplRights")
      true
    else
      false
    end
  end

  def is_not_restricted?(rights, type)
    # logger = Java::edu.illinois.library.cantaloupe.delegate.Logger
    rights_json = JSON.parse(rights)
    nypl_rights = rights_json['nyplRights']
    available_derivatives_for_ip = nypl_rights['availableDerivatives']['$']
    if type == "full_res"
      # logger.debug("FULL RES FILE ACCESS")
      available_derivatives_for_ip.include?('g') || available_derivatives_for_ip.include?('j') || available_derivatives_for_ip.include?('s') 
    else
      available_derivatives_for_ip.include?(type)
    end
  end

  def get_rights(image_id, ip)
    # for testing restricted uuid
    # uuid = '943f6f8f-f5cf-e0b8-e040-e00a18063cff'
    # for testing restricted image_id
    # image_id: 1992268
    # https://api.repo.nypl.org/api/v2/captures/rights/1992268
    fetch("captures/rights/#{image_id}", ip)
  end

  def fetch(path, ip)
    require 'net/http'
    require 'uri'
    # logger = Java::edu.illinois.library.cantaloupe.delegate.Logger
    #.logger.debug("API URL IS: #{api_url(path)}")
    # logger.debug("IPS ARE: #{ip}")

    uri = URI.parse(api_url(path))
    request = Net::HTTP::Post.new(uri)
    request.body = `'{"ips":["#{ip}"]}'`
    request.set_content_type("application/json")
    request["Accept"] = "application/json"
    request["Authorization"] = "Token token=#{Secret.api_configuration[:auth_token]}"
    
    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    
    # logger.debug("RESPONSE IS: #{response}")
    return response.body
  end

  def api_url(path)
    "#{Secret.api_configuration[:api_url]}/api/v2/#{path}"
  end

  ##
  # Used to add additional keys to an information JSON response. See the
  # [Image API specification](http://iiif.io/api/image/2.1/#image-information).
  #
  # @param options [Hash] Empty hash.
  # @return [Hash] Hash that will be merged into an IIIF Image API 2.x
  #                information response. Return an empty hash to add nothing.
  #
  def extra_iiif2_information_response_keys(options = {})
=begin
    Example:
    {
        'attribution' =>  'Copyright My Great Organization. All rights '\
                          'reserved.',
        'license' =>  'http://example.org/license.html',
        'logo' =>  'http://example.org/logo.png',
        'service' => {
            '@context' => 'http://iiif.io/api/annex/services/physdim/1/context.json',
            'profile' => 'http://iiif.io/api/annex/services/physdim',
            'physicalScale' => 0.0025,
            'physicalUnits' => 'in'
        }
    }
=end
    {}
  end

  ##
  # Adds additional keys to an Image API 3.x information response. See the
  # [IIIF Image API 3.0](http://iiif.io/api/image/3.0/#image-information)
  # specification and "endpoints" section of the user manual.
  #
  # @param options [Hash] Empty hash.
  # @return [Hash] Hash to merge into an Image API 3.x information response.
  #                Return an empty hash to add nothing.
  #
  def extra_iiif3_information_response_keys(options = {})
    {}
  end

  ##
  # Tells the server which source to use for the given identifier.
  #
  # @param options [Hash] Empty hash.
  # @return [String] Source name.
  #
  def source(options = {})
  end

  ##
  # @param options [Hash] Empty hash.
  # @return [String,nil] Blob key of the image corresponding to the given
  #                      identifier, or nil if not found.
  #
  def azurestoragesource_blob_key(options = {})
  end

  ##
  # @param options [Hash] Empty hash.
  # @return [String,nil] Absolute pathname of the image corresponding to the
  #                      given identifier, or nil if not found.
  #
  def filesystemsource_pathname(options = {})
    # logger = Java::edu.illinois.library.cantaloupe.delegate.Logger
    url = Secret.database_configuration[:url]
    username = Secret.database_configuration[:username]
    password = Secret.database_configuration[:password]
    default_image_path = Secret.storage_configuration[:default_image_path]
    connection = java.sql.DriverManager.get_connection(url, username, password)
    statement = nil
    uuid = nil
    begin
      query =  "SELECT UUID FROM file_store WHERE TYPE in ('j', 's', 'g', 'v', 'q', 'w', 'r', 't') "
      query += "AND FILE_ID = ? AND STATUS = 4 "
      query += "ORDER BY TYPE = 'j' DESC, TYPE = 's' DESC, TYPE = 'g' DESC, TYPE = 'v' DESC, TYPE = 'q' DESC, TYPE = 'w' DESC, TYPE = 'r' DESC, TYPE = 't' DESC"
      statement = connection.prepare_statement(query)
      statement.setString(1, context['identifier'])
      results = statement.execute_query
      if results.next
        uuid = results.getString('UUID')
        # logger.debug("UUID: #{uuid}")
        # else
        # logger.debug('NO RESULTS...')
      end
    ensure
      connection.close if connection
      statement.close if statement
    end
    
    path = nil
    if not uuid.nil?
      uuid =~ /(....)(....)\-(....)\-(....)\-(....)\-(....)(....)(..)../
      path = "/ifs/prod/repo/#{uuid[0..1]}/#{$1}/#{$2}/#{$3}/#{$4}/#{$5}/#{$6}/#{$7}/#{$8}/#{uuid}"
    end
    
    if path.nil? && default_image_path != nil
      default_image_path
    else
      path
    end
  end

  ##
  # @param options [Hash] Empty hash.
  # @return [String,Hash<String,String>,nil] String URI; Hash with `uri` key,
  #         and optionally `username` and `secret` keys; or nil if not found.
  #
  def httpsource_resource_info(options = {})
  end

  ##
  # @param options [Hash] Empty hash.
  # @return [String] Identifier of the image corresponding to the given
  #                  identifier in the database.
  #
  def jdbcsource_database_identifier(options = {})
  end

  ##
  # Returns either the media (MIME) type of an image, or an SQL statement that
  # can be used to retrieve it, if it is stored in the database. In the latter
  # case, the "SELECT" and "FROM" clauses should be in uppercase in order to
  # be autodetected. If nil is returned, the media type will be inferred some
  # other way, such as by identifier extension or magic bytes.
  #
  # @param options [Hash] Empty hash.
  # @return [String, nil]
  #
  def jdbcsource_media_type(options = {})
  end

  ##
  # @param options [Hash] Empty hash.
  # @return [String] SQL statement that selects the BLOB corresponding to the
  #                  value returned by `jdbcsource_database_identifier()`.
  #
  def jdbcsource_lookup_sql(options = {})
  end

  ##
  # @param options [Hash] Empty hash.
  # @return [Hash<String,Object>,nil] Hash containing `bucket` and `key` keys;
  #                                   or nil if not found.
  #
  # Stephen Schor: Setting bucket name here allows us to configure it as an environment variable
  # as opposed to setting it in the .properties file, which can't read environment variables.
  def s3source_object_info(options = {})
  end

  ##
  # Tells the server what overlay, if any, to apply to an image in response
  # to a request. Will be called upon all image requests to any endpoint if
  # overlays are enabled and the overlay strategy is set to `ScriptStrategy`
  # in the application configuration.
  #
  # N.B.: When a string overlay is too large or long to fit entirely within
  # the image, it won't be drawn. Consider breaking long strings with LFs (\n).
  #
  # @param options [Hash] Empty hash.
  # @return [Hash<String,String>,nil] For image overlays, a hash with `image`,
  #         `position`, and `inset` keys. For string overlays, a hash with
  #         `background_color`, `color`, `font`, `font_min_size`, `font_size`,
  #         `font_weight`, `glyph_spacing`,`inset`, `position`, `string`,
  #         `stroke_color`, and `stroke_width` keys.
  #         Return nil for no overlay.
  #
  def overlay(options = {})
  end

  ##
  # Tells the server what regions of an image to redact in response to a
  # particular request. Will be called upon all image requests to any endpoint
  # if redactions are enabled in the application configuration.
  #
  # @param options [Hash] Empty hash.
  # @return [Array<Hash<String,Integer>>] Array of hashes, each with `x`, `y`,
  #         `width`, and `height` keys; or an empty array if no redactions are
  #         to be applied.
  #
  def redactions(options = {})
    []
  end

  ##
  # Returns XMP metadata to embed in the derivative image.
  #
  # Source image metadata is available in the `metadata` context key, and has
  # the following structure:
  #
  # ```
  # {
  #     "exif": {
  #         "tagSet": "Baseline TIFF",
  #         "fields": {
  #             "Field1Name": value,
  #             "Field2Name": value,
  #             "EXIFIFD": {
  #                 "tagSet": "EXIF",
  #                 "fields": {
  #                     "Field1Name": value,
  #                     "Field2Name": value
  #                 }
  #             }
  #         }
  #     },
  #     "iptc": [
  #         "Field1Name": value,
  #         "Field2Name": value
  #     ],
  #     "xmp_string": "<rdf:RDF>...</rdf:RDF>",
  #     "xmp_model": https://jena.apache.org/documentation/javadoc/jena/org/apache/jena/rdf/model/Model.html
  #     "native": {
  #         # structure varies
  #     }
  # }
  # ```
  #
  # * The `exif` key refers to embedded EXIF data. This also includes IFD0
  #   metadata from source TIFFs, whether or not an EXIF IFD is present.
  # * The `iptc` key refers to embedded IPTC IIM data.
  # * The `xmp_string` key refers to raw embedded XMP data, which may or may
  #   not contain EXIF and/or IPTC information.
  # * The `xmp_model` key contains a Jena Model object pre-loaded with the
  #   contents of `xmp_string`.
  # * The `native` key refers to format-specific metadata.
  #
  # Any combination of the above keys may be present or missing depending on
  # what is available in a particular source image.
  #
  # Only XMP can be embedded in derivative images. See the user manual for
  # examples of working with the XMP model programmatically.
  #
  # @return [String,Model,nil] String or Jena model containing XMP data to
  #                            embed in the derivative image, or nil to not
  #                            embed anything.
  #
  def metadata(options = {})
  end

end

