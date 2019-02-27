angular.module 'evaluator'
  .config ($stateProvider) ->

    publicState =
      name: 'public'
      templateUrl: 'public/root.html'
      url: ''
      abstract: true
      data:
        authRule: (userAuth) ->
          if userAuth.signedIn
            {
              to: 'private.courses'
              params: {}
              allowed: false
            }
          else
            {
              allowed: true
            }

    loginState =
      name: 'public.login'
      url: '/login'
      views:
        'pageContent':
          templateUrl: 'public/login.html'
          controller: 'LoginController'
      resolve:
        $title: ->
          'Evaluator| Login'

    # signupState =
    #   name: 'public.signup'
    #   url: '/signup'
    #   views:
    #     'pageContent':
    #       templateUrl: 'public/signup.html'
    #       controller: 'SignupController'
    #   resolve:
    #     $title: ->
    #       'Evaluator| Signup'
    
    

    verifyAccount =
      name: 'public.verify'
      url: '/verify?token'
      views:
        'pageContent':
          templateUrl: 'generic/wait_message.html'
          controller: 'VerifyController'

    resetPass =
      name: 'public.reset'
      url: '/reset?token'
      views:
        'pageContent':
          templateUrl: 'public/reset.html'
          controller: 'ResetController'

    sendReset =
      name: 'public.reset_send'
      url: '/resetpass'
      views:
        'pageContent':
          templateUrl: 'public/reset_send.html'
          controller: 'SendResetController'
      resolve:
        $title: ->
          'Reset Password'

    sendVerification =
      name: 'public.verify_send'
      url: '/reverify'
      views:
        'pageContent':
          templateUrl: 'public/verify_send.html'
          controller: 'SendVerifyController'


    aboutState =
      name: 'public.about'
      url: '/about'
      views:
        'pageContent':
          templateUrl: 'public/about.html'
      resolve:
        $title: ->
          'Evaluator| About'

    internalErrorState =
      name: 'public.internal_error'
      url: '/oops'
      views:
        'pageContent':
          templateUrl: 'public/internal_error.html'

    welcomeState =
      name: 'public.welcome'
      url: '/welcome'
      views:
        'pageContent':
          templateUrl: 'public/welcome.html'

    contactState =
      name: 'public.contact'
      url: '/contact'
      views:
        'pageContent':
          templateUrl: 'public/contact.html'
          controller: 'ContactController'
      resolve:
        $title: ->
          'Evaluator| Contact'

    thanksFeedbackState =
      name: 'public.thanks_feedback'
      url: '/thanks'
      views:
        'pageContent':
          templateUrl: 'public/thanks_feedback.html'
      resolve:
        $title: ->
          'Thanks'

    $stateProvider
      .state publicState
      .state loginState
      .state aboutState
      .state internalErrorState
      .state resetPass
      .state verifyAccount
      .state sendReset
      .state sendVerification
      .state welcomeState
      .state contactState
      .state thanksFeedbackState
      





