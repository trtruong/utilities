#!/usr/bin/env python3
import jenkins


def triggerJob(username, token, jenkins_server_url, jobname, params):
  server = jenkins.Jenkins(jenkins_server_url, username=username, password=token)
  queueItem = server.build_job(jobname, params, {'token': token})
  while True:
    response = server.get_queue_item(queueItem)
    if not response:
      return None
    elif "executable" in response.keys() and response["executable"]:
      return response["executable"]["url"]
