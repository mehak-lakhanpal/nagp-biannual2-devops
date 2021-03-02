pipeline{
	environment{
		registry = 'mehaklakhanpal/devopssampleapplication'
		registryCredential = 'dockerhub_id'
		dockerImage = ''
	}
	agent any
	tools{
		maven 'Maven3'
		jdk 'JDK-8'
	}
	stages{
		stage('Checkout'){
			steps{
				checkout scm
			}
		}
		stage('Build'){
			steps{
				bat 'mvn clean install'
			}
		}
		stage('Test'){
			steps{
				bat 'mvn test'
			}
		}
		stage('Sonar'){
			steps{
				withSonarQubeEnv('Test_Sonar'){
					bat 'mvn sonar:sonar'
				}
			}
		}
		stage('Artifactory'){
			steps{
				rtMavenDeployer(
					id:'deployer',
					serverId:'123456789@artifactory',
					releaseRepo:'',
					snapshotRepo:''
				)
				rtMavenRun(
					pom:'pom.xml',
					goals:'clean install',
					deployerId:'deployer'
				)
				rtPublishBuildInfo(
					serverId:'123456789@artifactory'
				)
			}
		}
		stage('Build Image'){
			steps{
				script{
					dockerImage = docker.build registry+':%BUILD_NUMBER%'
				}
			}
		}
		stage('Push Image'){
			steps{
				script{
					docker.withRegistry('',registryCredential){
						dockerImage.push()
					}
				}
			}
		}
		stage('Stop Running Container'){
			steps{
				bat """
				for /f "delims=" %%i in ('docker ps -aqf "name=c-mehaklakhanpal"') do set con %%i
				echo %con%
				if defined con (
				docker stop %con%
				docker rm -f %con% )
				"""
			}
		}
		stage('Run image'){
			steps{
				bat 'docker run --name c-mehaklakhanpal -d -p 6200:8080 mehaklakhanpal/devopssampleapplication:%BUILD_NUMBER%'
			}
		}
		stage('Automated testing'){
			steps{
				bat 'mvn -f DemoSampleApp_selenium/pom.xml -Dhostname=localhost -Dport=6200 -Dcontext=testapp test'
			}
		}
	}
	post{
		always{
			publishHTML(target:[
				allowMissing:false,
				alwaysLinkToLastBuild:false,
				keepAll:true,
				reportDir:'\\DemoSampleApp_selenium\\target\\surefire-reports',
				reportFiles:'index.html',
				reportName:'Index.html'
			])
		}
	}
}