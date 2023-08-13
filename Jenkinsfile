node {
  stage('SCM') {
    checkout scm
  }
  stage('SonarQube Analysis') {
    def scannerHome = tool 'new-scn';
    withSonarQubeEnv() {
      sh "${scannerHome}/bin/new-scn"
    }
  }
}
