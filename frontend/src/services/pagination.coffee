###
Pagination helper service
###

angular.module 'evaluator'
  .factory 'Pagination', ($q) ->
    class Pagination
      constructor: (@resource, @pluralName, @params={}, @factory=_.identity,
        @pageSize=10) ->
          @data = []
          @loaded = false
          @currentPage = 1
          @totalPages = 0

      # Element Access
      at: (index, page=@currentPage) ->
        $q (resolve, reject) =>
          if not @loaded or @currentPage isnt page
            # Fetch the page
            @load page, resolve, reject, index
          else
            # Already have the page
            resolve @data[index]

      # Used internally to load pages
      load: (page, resolve, reject, index) ->
        @loaded = false
        # Success callback page
        success = (page) =>
          # Map data through factory function
          @data = (@factory item for item in page[@pluralName])
          @currentPage = page['page']
          @totalPages = page['total_pages']
          @loaded = true
          if index
            resolve @data[index]
          else
            resolve @data
        # Failure callback
        failure =  _.bind @loadFailure, @, reject
        queryOpts =
          page: page
          page_size: @pageSize
        # Add default params
        _.extend queryOpts, @params
        @resource.query queryOpts, success, failure

      loadFailure: (reject, response) ->
        console.error 'failed to load page', @currentPage, 'for', @resource
        reject response

      # Set the page
      page: (pageNum) ->
        $q (resolve, reject) =>
          if not @loaded or @currentPage != pageNum
            @load pageNum, resolve, reject
          else
            resolve @data

      hasPages: ->
        @currentPage < @totalPages

      # Force reload of currentPage
      reload: ->
        $q (resolve, reject) =>
          @load @currentPage, resolve, reject




      
    