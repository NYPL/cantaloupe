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
# This version of the script works with Cantaloupe version 5, and not earlier
# versions. Likewise, earlier versions of the script are not compatible with
# Cantaloupe 5.
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

  # We use ranges, although the upper bound is the expected value for the derivative type.
  # In practice, it can be a bit less.
  def derivative_type(size)
    height = size['height']
    longest_side = java.lang.Math.max(height, size['width'])

    case
    when longest_side <= 100
      'b'
    when (101..140).cover?(height)
      'f'
    when (141..150).cover?(longest_side)
      't'
    when (151..300).cover?(longest_side)
      'r'
    when (301..760).cover?(longest_side)
      'w'
    when (761..1600).cover?(longest_side)
      'q'
    when (1601..2560).cover?(longest_side)
      'v'
    else
      'full_res'
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
    # Short circuit the lookup if in the list of DC facelift image_ids
    if homepage_image_rights_hash.keys.include?(image_id)
      homepage_image_rights_hash[image_id]
    else
      # for testing restricted uuid
      # uuid = '943f6f8f-f5cf-e0b8-e040-e00a18063cff'
      # for testing restricted image_id
      # image_id: 1992268
      # https://api.repo.nypl.org/api/v2/captures/rights/1992268
      fetch("captures/rights/#{image_id}", ip)
    end
  end

  def fetch(path, ip)
    require 'net/http'
    require 'uri'
    require 'json'
    
    uri = URI.parse(api_url(path))
    
    request = Net::HTTP::Post.new(uri)
    request.body = "{\"ips\":[\"#{ip}\"]}"
    
    # for testing, uncomment the following lines: 
    # puts "This should include a real ip:"
    # puts request.body 
    
    request.content_type = 'application/json'
    request['Accept'] = 'application/json'
    request['Authorization'] = "Token token=#{Secret.api_configuration[:auth_token]}"

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    response = http.request(request)
    return response.body
  end

  def api_url(path)
    "https://api.repo.nypl.org/api/v2/#{path}"
  end
  
  def homepage_image_rights_hash
    {
      "58270299" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be displayed in digital exhibition\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"rightsNotes\":{\"$\":\"All works in collection published in Mexico pre-1940, with undated prints given an estimated date range of approx.1890-1920 by PRN. The copyright term in Mexico is 50 years after publication date, or 75 years after the death of the creator. (The current 100 year copyright term in Mexico started in 2003, but is not retroactive.) Under Article 104(a) of the Berne Convention this collection is in the public domain in both the US and Mexico, as copyright protections for all works expired before 1996.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "1408153" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "58300996" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Contract Restrictions Present (e.g., donor restrictions, license)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"ICCDPP\"},\"useStatementText\":{\"$\":\"This item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s).\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/InC/1.0/\"}}],\"rightsNotes\":{\"$\":\"rev.5.15.13 (broad uses)\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "58591658" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"UNDNFI\"},\"useStatementText\":{\"$\":\"The copyright and related rights status of this item has been reviewed by The New York Public Library, but we were unable to make a conclusive determination as to the copyright status of the item. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/UND/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "58498722" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"ICNYPL\"},\"useStatementText\":{\"$\":\"The New York Public Library holds or manages the copyright(s) in this item. If you need information about reusing this item, please go to: http://nypl.org/permissions\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/InC/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "1952272" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\"},\"useStatementText\":{\"$\":\"The copyright and related rights status of this item has been reviewed by The New York Public Library, but we were unable to make a conclusive determination as to the copyright status of the item. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/UND/1.0/\"}}],\"rightsNotes\":{\"$\":\"30th Anniversary Exhibit \\nFarm Security Administration photo\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "58447105" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDUSG\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"rightsNotes\":{\"$\":\"Date range is from October 1935 through May 1939, which is within the period that Abbott worked for FAP. No restrictions on any of the 344 B. Abbott photographs without people.  There may be rights of privacy and publicity for photos that contain people.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "1582202" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Contract Restrictions Present (e.g., donor restrictions, license)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"ICCDPP\"},\"useStatementText\":{\"$\":\"This item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s).\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/InC/1.0/\"}}],\"rightsNotes\":{\"$\":\"The Deed of Gift for this collection gives NYPL the right to make reproductions for only preservation purposes only.\\r\\n\\r\\nIn 2002, the Library received a letter from Davies granting the Library additional discretion in the use of the photos in the collection. The only requirement is that NYPL instructs all users to credit the photo with \\\"PHOTO BY\\\" instead of \\\"COURTESY OF.\\\"\\r\\n\\r\\nIn April of 2011, the donor called the curator in charge of her papers and verbally gave permission for the Library to license the photographs for non-commercial or editorial purposes. No papers or emails were sent to confirm.\\r\\n\\r\\nTherefore, any commercial uses (not including editorial) of these photographs must be referred to the representative. Also, any photographs of people may raise rights of publicity issues. No commercial uses of photographs with recognizable people is permitted for 50 years after the date of the subject, or 100 years after creation of the photograph if the subject's death date is unknown.\\r\\n\\r\\nUpon death of the donor, copyright will transfer to the Library.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "58734720" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Contract Restrictions Present (e.g., donor restrictions, license)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"ICCDPP\"},\"useStatementText\":{\"$\":\"This item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s).\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/InC/1.0/\"}}],\"rightsNotes\":{\"$\":\"Non-Exclusive License (with Deed of Gift, see attached) extends only to those works created by Saul Steinberg. All items created by a third-party (such as back issues of the New Yorker magazine included with the gift) are not covered by the NEL agreement and require a separate rights review and/or clearance. NEL allows broad uses; however RoP restrictions may apply to some drawings (depicting the likenesses of real people) and may be evaluated further at the item level.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "58495568" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Contract Restrictions Present (e.g., donor restrictions, license)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"ICCDPP\"},\"useStatementText\":{\"$\":\"This item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s).\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/InC/1.0/\"}}],\"rightsNotes\":{\"$\":\"Non-Exclusive License (with Deed of Gift, see attached) extends only to those works created by Saul Steinberg. All items created by a third-party (such as back issues of the New Yorker magazine included with the gift) are not covered by the NEL agreement and require a separate rights review and/or clearance. NEL allows broad uses; however RoP restrictions may apply to some drawings (depicting the likenesses of real people) and may be evaluated further at the item level.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "1945789" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Contract Restrictions Present (e.g., donor restrictions, license)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"ICCDPP\"},\"useStatementText\":{\"$\":\"This item is protected by copyright and/or related rights. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use. For other uses you need to obtain permission from the rights-holder(s).\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/InC/1.0/\"}}],\"rightsNotes\":{\"$\":\"5.15.13 NEL - Broad uses.\\r\\n\\r\\n2009 Deed of Gift includes the following non-exclusive license language: \\\"The Emilio Sanchez Foundation will allow the New York Public Library to use the donated pieces for all standard institution purposes including reproducing the works by methods involving photographic, electronic, and mechanical means in educational, promotional, archival, scholarly, or commercial purposes that directly benefit the New York Public Library, but not all unlimited rights.\\\" This has been interpreted to allow digitization and inclusion of the images on NYPL websites.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "5179162" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDUSG\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"rightsNotes\":{\"$\":\"\\\"An important development in the history of the [Art \\u0026 Artifacts] Collection occurred early in the 1940s with the dissolution of the Works Progress Administration. ...During the Depression a great many black American artists maintained themselves by working for the WPA, primarily at the Harlem Art Center... When the program was disbanded, a number of works commissioned by the WPA were apparently donated to the NYPL to be hung in its various branches, with many works by black artists given to the Schomburg Collections.\\\"--From the Bulletin of Research into the Humanities (Summer 1981)\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "5452683" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Release Source File for Free (i.e., high-res or master can be released to the public)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"rightsNotes\":{\"$\":\"Maps within this collection were produced before 1900. Therefore, all of them are in the public domain and can be used freely, without restriction.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "3928477" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Release Source File for Free (i.e., high-res or master can be released to the public)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "434724" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Release Source File for Free (i.e., high-res or master can be released to the public)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"rightsNotes\":{\"$\":\"None of the maps is dated after the mid 1800s. Therefore, all of them are in the public domain and can be used freely, without restriction.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "1516806" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Release Source File for Free (i.e., high-res or master can be released to the public)\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"rightsNotes\":{\"$\":\"The copyright status of the title, Topographical Survey of Portion of Central Park (1938-1948) is unclear. This title cannot be used commercially for at least 140 years from the date of creation. However, with the exception of these two items, the remaining images are in the public domain and can be used freely, without restriction.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "57066397" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "57879179" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "57502571" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"UNDNFI\"},\"useStatementText\":{\"$\":\"The copyright and related rights status of this item has been reviewed by The New York Public Library, but we were unable to make a conclusive determination as to the copyright status of the item. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/UND/1.0/\"}}],\"rightsNotes\":{\"$\":\"Multiple authors contributed to the Yizkor books, and they include clippings, text, and photographs from different sources and publications. \\r\\n\\r\\n650 books were digitized in conjunction with the National Yiddish Book Center (NYBC) in 2000. The agreement with NYBC has a few unique provisions:\\r\\nAll electronic rights in the book collection are property of NYPL\\r\\nNYBC has exclusive right to produce print and microform copies\\r\\nIf patrons want to purchase printed copies, NYPL will refer patron to NYBC\\r\\nNYBC warrants that it will make good-faith effort to identify and clear rights holders\\r\\n\\r\\n\\r\\nPlease refer to the 2012 Rights memo on Yizkor books for more information.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "56958645" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDREN\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "57555753" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PPD100\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"rightsNotes\":{\"$\":\"Some material within this collection has been identified with a creation date after 1898. These items have been given profiles at an item level.\\r\\n\\r\\nThe Century Company published periodicals and books. It was founded in New York City in 1881. Century's primary publication was The Century Illustrated Monthly Magazine, which was regarded as the best general periodical of its time during the 1880s and 1890s. The records consist of correspondence, manuscripts, vouchers, proofs of articles, and other materials concerning the publications of the Century Company. \\r\\n\\r\\nThe General Correspondences are presumed to be unpublished by the Rights dept. Given the amount of items in the MMS container, this determination cannot be made at the item level at this time. As unpublished correspondences, it is needed to determine if authors of material died in the US over 70 years ago. Research would also be needed to determine if material created under the Century Co. is owned by the Company or individual authors. 1923-1931 material would need confirmation of publication status. Below is the approved rights designation, determined by the Rights dept.:\\r\\n\\r\\nAt this time all correspondences created before 1896 are designated PPD\\u003E120 (all uses). If no author death date is determined and the item is created between 1896 and 1922 it will be designated as UND/NFI (Unpublished) (non-commercial uses) until more information can be ascertained. If it has been determined that an author died before 1945 (less than 70 years ago) than UND/NFI (Unpublished) (non commercial uses) (or PD/ADD if publication status is verified) may be added at an item level. Authors who died after 1945 (over 70 years ago) will be given a UND/NFI (Unpublished) distinction (on-site use only). If no author death date is determined and the creation date is after 1923, than UND/NFI (unpublished) (on-site only).\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "5661680" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDCDPP\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "57840965" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PPD100\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "psnypl_mss_986" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"$\":\"Can be used in advertising for NYPL exhibitions, on catalog covers, in press kits, or fundraising activities\"}},{\"use\":{\"$\":\"Can be sold through 3rd party print partner (e.g., New York Times)\"}},{\"use\":{\"$\":\"Can be licensed to 3rd party websites\"}},{\"use\":{\"$\":\"Can be used in products created by NYPL for commercial gain (e.g., Library Shop, CDs, DVDs, etc.)\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PPD100\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "1577406" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Copyright Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"UNDNFI\"},\"useStatementText\":{\"$\":\"The copyright and related rights status of this item has been reviewed by The New York Public Library, but we were unable to make a conclusive determination as to the copyright status of the item. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/UND/1.0/\"}}],\"rightsNotes\":{\"$\":\"The profile was set at a collection level because most digitized items in the collection shared a common rights status. If an item had the ACT UP trademark on it or was unattributed, I did not create an item-level profile. Profiles for individual items have been created for items that do not appear to have been under the ACT UP umbrella or contained copyright notices listing others as authors.\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "808351" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\"},\"useStatementText\":{\"$\":\"The copyright and related rights status of this item has been reviewed by The New York Public Library, but we were unable to make a conclusive determination as to the copyright status of the item. You are free to use this Item in any way that is permitted by the copyright and related rights legislation that applies to your use.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/UND/1.0/\"}}],\"rightsNotes\":{\"$\":\"Over 30,000 images arranged alphabetically by subject.  Most of these images were clipped from publications. The image details vary from one image to another. Some may contain a published date but no original source information, so the place of publication cannot be determined. Regarding copyright, if the publication source is listed and is American and the publication date is before 1923, or if published abroad and at least 140 years from the date of creation, then the use is unrestricted for images that do not contain people. Otherwise, there can be no commercial uses of these images. For images containing people there are additional privacy/publicity considerations. To avoid possible rights of publicity claims, it is NYPL's policy that, in the case of photos for which we don't have releases from the people in the photos, such as these images, NYPL should not use the images commercially (e.g., in merchandise or on sites like Flickr) until the earlier of the following two dates: (i) 50 years after the death of the person in the photo or (ii) 120 years after the date the photo was taken (if the person in the photo is a child), or 100 years after the date the photo was taken (if the person in the photo is an adult).  If the photo contains a child and an adult, and you aren't sure that they have both been dead for at least 50 years, then please apply the more restrictive rule (i.e., only use the photo if it was created at least 120 years ago.)\"},\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"r\\\", \\\"w\\\"]\"}}}",
      "58507228" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDNCN\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}",
      "58613681" => "{\"nyplRights\":{\"useStatement\":[{\"use\":{\"$\":\"Right of Publicity Issues Present\"}},{\"use\":{\"$\":\"Can be displayed on NYPL premises\"}},{\"use\":{\"$\":\"Can be used on NYPL website\"}},{\"use\":{\"$\":\"Can be used inside free NYPL exhibition catalogs and in free NYPL brochures\"}},{\"use\":{\"type\":\"copyright_status\",\"$\":\"PDNCN\"},\"useStatementText\":{\"$\":\"The New York Public Library believes that this item is in the public domain under the laws of the United States, but did not make a determination as to its copyright status under the copyright laws of other countries. This item may not be in the public domain under the laws of other countries. Though not required, if you want to credit us as the source, please use the following statement, \\\"From The New York Public Library,\\\" and provide a link back to the item on our Digital Collections site. Doing so helps us track how our collection is used and helps justify freely releasing even more content in the future.\"},\"useStatementURI\":{\"$\":\"http://rightsstatements.org/vocab/NoC-US/1.0/\"}}],\"isRestrictedForIP\":{\"$\":\"false\"},\"availableDerivatives\":{\"$\":\"[\\\"t\\\", \\\"f\\\", \\\"b\\\", \\\"q\\\", \\\"v\\\", \\\"g\\\", \\\"r\\\", \\\"w\\\", \\\"s\\\", \\\"j\\\"]\"}}}"
    }
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

