# Known Issues


- Authentication errors for a user with appropriate permissions but not in the Default Domain.
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
