Application Setup
Prerequisites
4.	Python: Have Python 3.x installed.
5.	pip: This usually comes with Python.
6.	A code editor: Visual Studio Code
Step 1: Create a Project Directory
3.	Open your terminal or command prompt.
4.	Create a new directory for your project and navigate into it:
mkdir python_web_app
cd python_web_app
Step 2: Create a Virtual Environment
3.	Create a virtual environment:
python -m Web_app venv
4.	Activate the virtual environment:
Web_app \Scripts\activate
Step 3: Create the Python Application
3.	Create a new Python file:
touch app.py
4.	Open app.py in your code editor and add simple code
Step 4: Install Flask
Once virtual environment is activated (you should see (Web_app) in your terminal).
Install Flask using pip:
pip install Flask
Step 5: Run the Application
In your terminal, run the application:
python app.py
You should see output indicating that the server is running, typically on 5000 port.
Step 6: Access the Application
3.	Open your web browser.
4.	Go to localhost:5000
You should see the message displayed in your browser.
Step 7: Stop the Application
To stop the application, return to your terminal and press Ctrl + C.

Push Files to GitHub repository
1. Navigate to Your Project Directory
Open your terminal and navigate to the directory containing your project files:
cd path/to/your/project
2. Initialize a Local Git Repository
git init
3. Add Remote Repository
git remote add origin <repository-url>
4. Add Files to Staging Area
git add .
5. Commit Your Changes
git commit -m "Initial commit"
6. Rename branch 
git branch -M main
7. Push to repository
git push -u origin main

Pipeline overview
Workflow Details
Prerequisites
•	Ensure EC2 instances have Docker, Git, and Ansible installed, or pipeline is configured to install them.
•	The necessary security groups and firewall rules should allow SSH access and HTTP traffic to the application.
Key Steps in the Workflow
1.	Checkout Code:
o	The workflow starts by checking out the code from the repository using actions/checkout@v2.
2.	Log in to Docker Hub:
o	The workflow logs into Docker Hub using the credentials stored in GitHub Secrets (DOCKER_HUB_USERNAME and DOCKER_HUB_ACCESS_TOKEN).
3.	Build and Deploy to Development EC2:
o	This job uses appleboy/ssh-action@master to SSH into the development EC2 instance.
o	It installs Git and Ansible if they are not already installed.
o	The script checks if the application directory exists. If it does not, it clones the repository.
o	It then pulls the latest changes and executes the Ansible playbook for the development configuration (configuration_dev.yml).Passes the Docker Hub username, dockerhub password as an extra variable to the playbook.
5.	Deploy to Production EC2:
o	Similar to the development job, this job connects to the production EC2 instance.
o	It performs the same checks and operations: installs Git and Ansible, clones the repository if needed, and executes the Ansible playbook for the production configuration (configuration_prod.yml). Passes the Docker Hub username, dockerhub password as an extra variable to the playbook.
Secrets 
Ensure that the following secrets are set in your GitHub repository settings under "Secrets" for this workflow to run successfully:
•	DOCKER_HUB_USERNAME: Your Docker Hub username.
•	DOCKER_HUB_ACCESS_TOKEN: Your Docker Hub access token.
•	DEV_IP_ADDRESS: The IP address of your development EC2 instance.
•	PROD_IP_ADDRESS: The IP address of your production EC2 instance.
•	SSH_PRIVATE_KEY: Your SSH private key for connecting to the EC2 instances.

Structure of the Dockerfile
The Dockerfile consists of three main stages: builder, tester, and final. Each stage is designed to handle specific tasks efficiently.
1. Builder Stage
•	Base Image:
o	Uses the official python:3.9-slim image as the base for building the application.
•	Working Directory:
o	Sets the working directory to /app.
•	Install Dependencies:
o	Copies requirements.txt to the container.
o	Installs the required Python packages listed in requirements.txt using pip with the --no-cache-dir option to reduce image size.
•	Copy Application Code:
o	Copies the rest of the application code into the container.
2. Tester Stage
•	Environment Variable:
o	Sets PYTHONPATH to the current working directory to ensure the application can be found when running tests.
•	Run Tests:
o	Executes tests using pytest. Ensure that pytest is included in the requirements.txt file.
3. Final Stage
•	Base Image:
o	Again uses the python:3.9-slim image for the final runtime environment.
•	Working Directory:
o	Sets the working directory to /app.
•	Copy Necessary Files:
o	Copies application files and installed packages from the builder stage to the final image.
•	Expose Port:
o	Exposes port 5000 for the Flask application.
•	Run Command:
o	Specifies the command to run the application: CMD ["python", "app.py"].

Structure of ansible playbook for dev and prod
Key Tasks Dev
1.	Update Package Index and Install Docker:
o	Updates the apt package index and installs Docker if it is not already installed.
2.	Verify Docker Installation:
o	Checks the installed version of Docker and outputs it.
3.	Remove Old Dangling Images:
o	Identifies and removes any old, dangling Docker images related to the application.
4.	Build Docker Image:
o	Builds the Docker image for the application using the Dockerfile located in the /home/ubuntu/python-app directory.
5.	Run Tests:
o	Executes tests using pytest in a Docker container to ensure that the application is functioning correctly.
6.	Log in to Docker Hub:
o	Logs into Docker Hub using the specified credentials.
7.	Push Docker Image to Docker Hub:
o	Pushes the newly built Docker image to Docker Hub for storage and access.
8.	Manage Existing Containers:
o	Checks if a container with the specified name exists and stops it if it does.
o	Removes the existing container if it is present.
9.	Run the Docker Container:
o	Starts a new instance of the application container with specified port mappings.
Key Tasks Prod
1.	Update Package Index and Install Docker:
o	Updates the apt package index and installs Docker if it is not already installed.
2.	Verify Docker Installation:
o	Checks the installed version of Docker and outputs it.
3.	Pull Latest Docker Image:
o	Pulls the latest version of the Docker image from Docker Hub.
4.	Manage Existing Containers:
o	Checks if a container with the specified name exists and stops it if it does.
o	Removes the existing container if it is present.
5.	Run the Docker Container:
o	Starts a new instance of the application container with specified port mappings.

Structure of inventory file
•  Group Name: dev, prod
•	This section contains hosts that belong to the development environment and production environment.
•  Host Definition:
•	dev-server: A name you can use to refer to this server within your Ansible playbooks.
•	ansible_host: The actual IP address of the development server.
•	prod-server: A name for the production server, used within Ansible.
•	ansible_host: The actual IP address of the production EC2 instance.
•  Global Variables: This section defines variables that apply to all hosts.
•	ansible_user=ubuntu: The default user to connect to the servers via SSH

Test file structure
•  Importing Dependencies:
•	pytest: The testing framework used for writing and executing test cases.
•	sys, os: These modules are used to manipulate the Python path to include the parent directory. This allows for proper module resolution when importing the Flask application
•  Setting Up the Python Path:
To enable the test file to access the application code in the parent directory
•  Importing Flask application
It line pulls in the application instance defined in app.py, allowing the tests to simulate HTTP requests against it.
•  Fixture:
•	client(): A pytest fixture that creates a test client for the Flask application. This allows you to simulate requests to your application.
•  Test Case:
•	test_homepage(client): A function that tests the homepage of the application.
o	Sends a GET request to the homepage (/).
o	Asserts that the response status code is 200 OK.
o	Checks that the response content contains the text "Welcome to IQVIA!".

Dependencies
The following packages are included in the requirements.txt file:
5.	Flask: Version 2.1.2
o	A lightweight WSGI web application framework in Python. It is designed to make getting started quick and easy, with the ability to scale up to complex applications.
6.	Jinja2: Version 3.0.3
o	A modern and designer-friendly templating language for Python, used by Flask to render HTML templates.
7.	Werkzeug: Version 2.0.3
o	A comprehensive WSGI web application library that powers Flask. It provides utilities for building web applications in Python.
8.	pytest
o	A framework that makes building simple and scalable test cases easy. It is used for writing and running tests for your Flask application.
