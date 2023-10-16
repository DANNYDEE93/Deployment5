## <ins>Deployment 5: Run a Jenkins Build for a Banking Application and Deploy it to a second instance using SSH </ins>
_________________________________________________
##### Danielle Davis
##### October 15, 2023
______________________________________
### <ins>PURPOSE:</ins>
___________________
&emsp;&emsp;&emsp;&emsp;	SSHing to a separate server for application deployment.

Previously, we manually built, tested, and deployed our web application on a single server. In our updated deployment process, we utilize Terraform to create the infrastructure. However, we now build and test the application on one server before SSHing into a second server for the deployment process.

### <ins>ISSUES:</ins>
___________________
*Most of the challenges revolved around the development process, including writing and testing code, identifying bugs, and debugging code within the Terraform files, as well as making necessary edits in the Jenkinsfiles and setup files


### <ins> **STEPS FOR WEB APPLICATION DEPLOYMENT** </ins>

_____________________________________________________________________________
### Step 1: Create terraform file:
__________________________________________________________________________
	
* Terraform is a great tool to automate the creation of infrastructure 
* Use terraform to automate the creation of a VPC and the necessary dependencies, along with a web and application server provisioned through 2 different instances in the public subnet.
* See main.tf file here

* Automate the Building of the Application Infrastructure
For this application infrastructure, we want:


* 1 VPC
2 Availability Zones
2 Public Subnets
2 EC2 Instances
1 Route Table
2 Security Group 
  -one with ports: 22 and 8000
  -another with ports: 22 and 8080
To automate the construction of the application infrastructure, employ an instance equipped with VS Code and Terraform. The main.tf and variables.tf files, define the resources to be created and declare variables. Additionally, Terraform enables the execution of installation scripts. In the case of one instance, an installation script was utilized for installing Jenkins.

Jenkins

Jenkins is used to automate the Build, Test, and Deploy the Banking Application. To use Jenkins in a new EC2, all the proper installs to use Jenkins and to read the programming language that the application is written in need to be installed. In this case, they are Jenkins, Java, and Jenkins additional plugin "Pipeline Keep Running Step", which is manually installed through the GUI interface.

______________________________________________________________________________
### Step 2: Git commits
__________________________________________________________________________

* I used git code through remote repository in VS code provisioned on a separate instance and made changes to the Jenkinsfile in a second branch to double check the changes before adding, committing, and pushing those changes to my local repository on Github.
  
* Add GitHub URL in config file to give code editor permission to update my local repo. 

	
![](https://github.com/DANNYDEE93/Deployment4/blob/main/static/dep4remoterepo.jpg)
_______________________________________________________________________

<ins> **Additions to application files through VS code editor** </ins>

The changes I made to the Jenkinsfiles includes the dependencies to sustain the virtual environment for the build stage, save the test stage results, and delete old builds and running processes attached to them. The script also installs dependencies for Gunicorn and Flask applications to run as a HTTP web server that runs python applications. The Gunicorn server can then run as a daemon or an automated dormant background process to handle client requests when necessary, preventing the server from getting overwhelmed.

___________________________________________
<ins> **Initial Deployment** </ins>
________________________________________

**Jenkinsfile1**

___________________________________________
<ins> **Second Deployment** </ins>
___________________________________________

**Jenkinsfile2**
**Setup2.sh**
**Change HTML file**

* When a **git pull** and **git push** those changes from the remote repo to the local repo that will be connected to Jenkins for my build.


_________________________________________________________________________________




### Step 3: Establish an SSH Connection from the Jenkins Server to the Application Server
While the Jenkins Server initiates the deployment process for the application, it does not perform the deployment itself. Instead, it establishes an SSH connection to the application server and runs a script to deploy the application. To accomplish this, an SSH connection is established using a Jenkins User account.

**Command to establish SSH Connection as Jenkins user: **

#In the Jenkins Server run the following bash commands
sudo passwd jenkins
sudo su - jenkins -s /bin/bash
ssh-keygen  #This will generate the public key to /var/lib/jenkins/.ssh/id_rsa.pub
#Copy the public key from the file id_rsa.pub
#Paste the key in /home/ubuntu/.ssh/authorized_keys file
#Then in the Jenkins server as a Jenkins user, run the command below to test the SSH connection
ssh ubuntu@application_server_ip_address

SSH Connection was made:pngg


________________________________________________________________________

### Step 4:

In both instances, as an ubuntu user, install the following:

sudo apt update
sudo apt install -y software-properties-common 
sudo add-apt-repository -y ppa:deadsnakes/ppa 
sudo apt install -y python3.7 
sudo apt install -y python3.7-venv



### Step 5:

Step #7 Configure Jenkins Build and Run Build


Create Jenkins Multibranch Pipeline Build for staging environment: Find instructions in previous deployment to access Jenkins in the web browser, create a multibranh pipeline, and how to create a token to link GitHub repository with the application code to Jenkins:: here [deployment4]

Jenkins Build: In Jenkins create a build "deploy_5" for the Banking application from GitHub Repository https://github.com/LamAnnieV/deployment_4.git and run the build. This build consists of four stages: The Build, the Test, the Clean, and the Deploy stages. [See the importance of these stages [here]]

Please refer back to "Edit to the Jenkinsfilev1" and "Edit to the setup.sh" above for changes.

Result

Jenkins build "deploy_5" was successful:




__________________________________________________________________________

### Step 9: Nginx, Gunicorn and Flask Production Environment 

__________________________________________________________________________

* Copy and paste public ip address and port 8000 (this port is necessary to access Gunicorn server) in a new browser to run the deployment through the nginx extension that we installed on the server <ip_address:8000>


![](https://github.com/DANNYDEE93/Deployment4/blob/main/static/urlshortener.jpg)


* Nginx acts as a reverse proxy server/middleman between the EC2 instance and the web application. It creates a level of security by buffering requests and only allowing necessary responses from the backend. This can also potentially handle traffic from overloading the web application server.
* Gunicorn, installed with the code in our application code, acts as a proxy server running on port 8000 adding into the configuration file in Nginx. Gunicorn was installed in the application code changes I made in the Jenkinsfile. The flask application uses python with Gunicorn to create a framework or translation of the python function calls into HTTP responses so that Gunicorn can access the endpoint which was the application URL.

   
__________________________________________________________________________



______________________________________________________________________________

### <ins>RE-BUILD & DEPLOY:</ins>
__________________________________________________________________



![](https://github.com/DANNYDEE93/Deployment4/blob/main/static/rebuild%26alarm.jpg)

&emsp;&emsp;&emsp;&emsp;		As I explained above in my **Issues** section and **Step 9**, I had to rebuild my staging environment in Jenkins for my application to deploy. Re-running the build in Jenkins ensured that all changes and dependencies were refreshed and updated,  as well as that the cache history was cleared out old builds. Most importantly, it ensures a greater level of optimization because by testing in Jenkins, I can identify any errors in the code before pushing the build to the production environment.

&emsp;&emsp;&emsp;&emsp;		For my CloudWatch alarm, I chose to measure the **CPU User Usage** and set the alarm to notify me when the usage gets over 75% and adjusted the percentage to assess the notification process. I saw that the CPU usage went all the way up to 80% after rebuilding the application in Jenkins due to all  the processing power that its using to complete so many different tasks at once.

&emsp;&emsp;&emsp;&emsp;			After running my Jenkins build a few times and installing all the applications on my EC2 instance, it had some connectivity issues. It was performing at a slower pace but still worked well enough for my deployment. Luckily, I used a t2.medium EC2 instance because my usual t2.micro instance would not have been able to manage all the installations I added to it. For the long term, I would need to eventually switch to an instance with a larger capacity just in case I need to install additional applications or perform more complicated processes. This issue is important to note especially for understanding business needs and infrastructure scalability. 


_____________________________________________

### <ins>SYSTEM DIAGRAM:</ins>
_________________________________________________


![](https://github.com/DANNYDEE93/Deployment4/blob/main/static/newdep4.jpg)

_________________________________________________

### <ins>OPTIMIZATION:</ins>
_____________________________________________
Jenkins was particularly important in the optimization and error handling for the deployment. Below are some ways I could have had better optimization with my deployment:

In this deployment, two instances are employed: one for the Jenkins server and the other for the Web application server. Both instances are placed in the public subnet, as they need to be accessible via the internet. The Jenkins server is accessible through port 8080 for utilizing the Jenkins GUI interface, while the application server is accessible by our banking customers through port 8000. Thus, both subnets must remain public for these connections to function as required.

Enhance automation of the AWS Cloud Infrastructure by implementing Terraform modules.
*Create webhook to automatically trigger Jenkins build when there are changes to my GitHub repository
