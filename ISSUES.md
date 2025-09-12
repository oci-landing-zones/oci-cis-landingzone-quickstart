# Known Issues


- Authentication errors for a user with appropriate permissions but not in the Default Domain. Sample error `oci.exceptions.ServiceError {'target_service': 'identity', 'status': 401, 'code': 'NotAuthenticated', 'opc-request-id': ', 'message': 'The required information to complete authentication was not provided or was incorrect.', 'operation_name': 'list_availability_domains', 'timestamp': '2025-08-20T08:32:39.587537+00:00', 'client_version': 'Oracle-PythonSDK/2.158.0', 'request_endpoint': 'GET https://identity.eu-paris-1.oci.oraclecloud.com/20160918/availabilityDomains', 'logging_tips': 'To get more info on the failing request, refer to https://docs.oracle.com/en-us/iaas/tools/python/latest/logging.html for ways to log the request/response details.', 'troubleshooting_tips': "See https://docs.oracle.com/iaas/Content/API/References/apierrors.htm#apierrors_401__401_notauthenticated for more information about resolving this error. Also see https://docs.oracle.com/iaas/api/#/en/identity/20160918/AvailabilityDomain/ListAvailabilityDomains for details on this operation's requirements. If you are unable to resolve this identity issue, please contact Oracle support and provide them this full error message."}`
  - Enable replication if users in an identity domain need to interact with OCI resources in regions beyond that domain's home region. For example, if the domain was created with Germany Central (Frankfurt) as its home region, replication to France Central (Paris) lets users in the domain interact with OCI resources in Frankfurt or Paris, but not US East (Ashburn), even if the tenancy is subscribed to that region. Read more [here](https://docs.oracle.com/en-us/iaas/Content/Identity/domains/to-manage-regions-for-domains.htm)

- Error while processing Identity Domains like `__identity_read_groups_and_member_ship: error reading ... {'messageId': 'error.identity.group.maxMembersLimit}`
    - This is issue is being worked on. In the meantime other checks will complete with out issue.
-  XLSX write will fail when cell values are too big
   * This is a known limitation of Excel and will only happen if the xlsxwriter library has been installed. The XLSX writing
     routine will be executed after the tenancy has been checked and all findings are written to CSV files. This issue does
     not impact the overall verification result of script.
- Diagrams are not part of the HTML page.
   * This may be because of broken `numpy` installation. The following command should resolve this:
   `pip3 install --upgrade --force-reinstall --user numpy`
