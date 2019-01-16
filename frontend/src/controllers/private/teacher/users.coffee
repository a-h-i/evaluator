angular.module 'evaluator'
  .controller 'UsersController', ($scope, Pagination, defaultPageSize,
    UsersResource, User, deletedUserIds) ->
      $scope.studentsOnly = false
      $scope.teachersOnly = false
      $scope.superUser = false
      $scope.loading = true
      $scope.loadingUsers = false
      $scope.searchData =
        name: ''
        email: ''
        team: ''
        guc_prefix: ''
        guc_suffix: ''
      
      $scope.params =
        name: null
        email: null
        guc_suffix: null
        guc_prefix: null
        student: null
        super_user: null
        team: null

      studentKeys = ['guc_prefix', 'guc_suffix',
      'team']
      studentsDisabled = false

      $scope.userClasses = ['user-accent-one',
        'user-accent-two', 'user-accent-three']

      setIfValid = (value, key)->
        if value && value.length > 0
          $scope.params[key] = value

      disableStudentOnlyParams = ->
        studentsDisabled = true
        $scope.params[key] = null for key in studentKeys
        return

      enableStudentOnlyParams = ->
        studentsDisabled = false
        setIfValid($scope.searchData[key], key) for key in studentKeys
        return

      $scope.$watch 'searchData', (newValue) ->
        changed = false
        for key, value of newValue
          if !studentsDisabled or key not in studentKeys
            oldParamValue = $scope.params[key]
            if value && value.length > 0
              $scope.params[key] = value
            else
              $scope.params[key] = null
            changed |= oldParamValue != $scope.params[key]
        $scope.reload() if changed
        return
      , true

      $scope.$watch 'superUser', (newValue) ->
        if newValue
          $scope.params.super_user = true
        else
          $scope.params.super_user = null
        $scope.reload()

      $scope.$watch 'teachersOnly', (newValue, oldValue) ->
        if newValue
          $scope.params.student = false
          disableStudentOnlyParams()
          $scope.reload()
          $scope.studentsOnly = false
        else
          enableStudentOnlyParams()
          if !$scope.studentsOnly
            $scope.params.student = null
            $scope.reload()

      $scope.$watch 'studentsOnly', (newValue, oldValue) ->
        if newValue
          $scope.params.student = true
          $scope.reload()
          $scope.teachersOnly = false
        else
          if !$scope.teachersOnly
            $scope.params.student = null
            $scope.reload()
   
      $scope.users = []

      addUsersCallback = (newUsers) ->
        users = newUsers.filter (user) ->
          user.id not in deletedUserIds
        args = [0, $scope.users.length].concat users
        $scope.users.splice.apply $scope.users, args

      userDeletedCallback = (user) ->
        deletedUserIds.push user.id
        _.remove $scope.users, (e) ->
          e.id is user.id

      userFactory = (data) ->
        new User(data, userDeletedCallback)

      usersPagination = new Pagination UsersResource, 'users', $scope.params,
        userFactory, defaultPageSize


      $scope.currentPage = 1

      $scope.reload = ->
        return if $scope.loadingUsers
        $scope.loadingUsers = true
        usersPagination.reload().then (users) ->
          $scope.loading = false
          $scope.loadingUsers = false
          addUsersCallback users

      loadUsersPage = (page) ->
        $scope.loadingUsers = true
        usersPagination.page(page).then (users) ->
          $scope.loading = false
          $scope.loadingUsers = false
          $scope.currentPage = page
          addUsersCallback users

      # Load first page
      loadUsersPage $scope.currentPage

      $scope.backDisabled = ->
        $scope.currentPage is 1

      $scope.nextDisabled = ->
        $scope.currentPage >= usersPagination.totalPages

      $scope.next = ->
        if not $scope.nextDisabled()
          loadUsersPage($scope.currentPage + 1)

      $scope.back = ->
        if not $scope.backDisabled()
          loadUsersPage($scope.currentPage - 1)

