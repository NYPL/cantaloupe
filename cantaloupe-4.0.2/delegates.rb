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
  # @return [Boolean] Whether the request is authorized.
  #
  def authorized?(options = {})
    true
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

end
