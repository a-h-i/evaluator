angular.module 'evaluator'
  .factory 'endpoints', (apiHost) ->
    endpoints =
      configurations:
        index: [apiHost, 'configurations.json'].join '/'
      users:
        resourceUrl: [apiHost, 'users', ':id.json'].join '/'
      courses:
        resourceUrl: [apiHost, 'courses', ':id.json'].join '/'
      courseProjects:
        resourceUrl: [apiHost, 'courses', ':course_id',
          'projects.json'].join '/'
      project:
        resourceUrl: [apiHost, 'projects', ':id.json'].join '/'
        bundle:
          resourceUrl: [apiHost, 'project_bundles.json'].join '/'
          downloadUrl: [apiHost, 'project_bundles', ':id', 'download'].join '/'
      projectSuites:
        resourceUrl: [apiHost, 'projects', ':project_id',
          'test_suites.json'].join '/'
      suite:
        resourceUrl: [apiHost, 'test_suites', ':id.json'].join '/'
        downloadUrl: [apiHost, 'test_suites', ':id', 'download'].join '/'
      projectSubmissions:
        resourceUrl: [apiHost, 'projects', ':project_id',
          'submissions.json'].join '/'
      submission:
        resourceUrl: [apiHost, 'submissions', ':id.json'].join '/'
        downloadUrl: [apiHost, 'submissions', ':id', 'download'].join '/'
        rerunUrl: [apiHost, 'submissions', ':id', 'rerun.json'].join '/'
      projectResults:
        resourceUrl: [apiHost, 'projects', ':project_id',
          'results.json'].join '/'
        csv: [apiHost, 'projects', ':project_id', 'results', 'csv'].join '/'
      result:
        resourceUrl: [apiHost, 'results', ':id.json'].join '/'
      teamGrades:
        latest: [apiHost, 'projects', ':project_id', 'team_grades',
          'latest.json'].join '/'
      teamsJob:
        url: [apiHost, 'teams.json'].join '/'
      contacts:
        resourceUrl: [apiHost, 'contacts.json'].join '/'
