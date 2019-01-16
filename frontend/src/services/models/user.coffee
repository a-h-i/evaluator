angular.module 'evaluator'
  .factory 'User', (UsersResource, moment) ->
    class User
      constructor: (data, @deletedCallback=angular.noop) ->
        @resource = new UsersResource(data)
        _.assign @, @resource

      reload: ->
        console.log(@resource.id)
        UsersResource.get({id: @resource.id}).$promise.then (resource) =>
          @resource = resource
          return @

      $update: (args...) ->
        @resource.$update(args...)

      $delete: (args...) ->
        @resource.$delete(args...).then (response) =>
          @deletedCallback(@)
          return response

      @property 'verified',
        get: ->
          @resource.verified
        set: (value) ->
          @resource.verified = value

      @property 'id',
        get: ->
          @resource.id
      
      @property 'student',
        get: ->
          @resource.student

      @property 'admin',
        get: ->
          @resource.super_user
        set: (value) ->
          @resource.super_user = value

      @property 'teacher',
        get: ->
          !@resource.student

      @property 'name',
        get: ->
          @resource.name
        set: (value) ->
          @resource.name = value

      @property 'full_name',
        get: ->
          @resource.full_name

      @property 'created_at',
        get: ->
          moment(@resource.created_at).format("MMMM Do YYYY, h:mm:ss a")

      @property 'email',
        get: ->
          @resource.email

      @property 'guc_id',
        get: ->
          @resource.guc_id
        set: (value) ->
          @resource.guc_id = value

      @property 'guc_suffix',
        get: ->
          @resource.guc_suffix
        set: (value) ->
          @resource.guc_suffix = value

      @property 'guc_prefix',
        get: ->
          @resource.guc_prefix
        set: (value) ->
          @resource.guc_prefix = value

      @property 'team',
        get: ->
          @resource.team
        set: (value) ->
          @resource.team = value

      @property 'password',
        get: ->
          @resource.password
        set: (value) ->
          @resource.password = value

      @property 'major',
        get: ->
          @resource.major
        set: (value) ->
          @resource.major = value
