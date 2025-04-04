# Install Nginx using Ansible
# Start and Enable Nginx
# Check the status of Nginx
- name: Setup Nginx server on myserver list
  hosts: web
  become: true
  tasks:
    - name: Install the latest version of Nginx
      command: sudo yum install nginx -y
      args:
        creates: /sbin/nginx

    - name: Start Nginx
      service:
        name: nginx
        state: started

    - name: Enable Nginx
      service:
        name: nginx
        enabled: yes

    - name: Ensure Nginx is at the latest version
      command: nginx -v

    - name: Get status of installed Nginx
      command: systemctl status nginx

    - name: Ansible copy file to remote server
      copy:
        src: /home/ec2-user/sample.txt
        dest: /home/ec2-user/sample.txt

    - name: Deploy HTML file
      copy:
        src: /home/ec2-user/index.html
        dest: /usr/share/nginx/html/index.html
