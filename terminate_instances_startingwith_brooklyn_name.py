import boto3

ec2 = boto3.resource('ec2')
ec2client=boto3.client('ec2')
def lambda_handler(event,context):
    print(str(event))

    response = ec2client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': ['brooklyn*']
            }
        ]
    )
    instancelist = []
    
    for reservation in (response["Reservations"]):
      for instance in reservation["Instances"]:
          instancelist.append(instance["InstanceId"])
          ec2.instances.filter(InstanceIds=instancelist).terminate()
    return instancelist