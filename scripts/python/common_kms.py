#!/usr/bin/env python3
import boto3
import base64
import os
import argparse

def initializedKMSResource(region, session=None):
  if session:
    client = session.client('kms', region_name=region)
  else:
    client = boto3.client('kms', region_name=region)
  return client

def get_base64_key(keyid, plaintext, region, session=None):
    client = initializedKMSResource(region, session)
    response = client.encrypt(
      KeyId=keyid,
      Plaintext=plaintext
    )

    ciphertext = response['CiphertextBlob']
    return base64.b64encode(ciphertext)


def get_plaintext_key(CiphertextBlob, region, session=None):
    blob = base64.b64decode(CiphertextBlob)
    client = initializedKMSResource(region, session)
    response = client.decrypt(
      CiphertextBlob=blob
    )
    return base64.b64encode(response['Plaintext'])
