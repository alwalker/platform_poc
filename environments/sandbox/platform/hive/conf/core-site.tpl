<configuration>
  <property>
    <name>fs.azure.account.auth.type.${storage_account_url}.dfs.core.windows.net</name>
    <value>SharedKey</value>
    <description>
    </description>
  </property>
  <property>
    <name>fs.azure.account.key.${storage_account_url}.dfs.core.windows.net</name>
    <value>${storage_account_key}</value>
    <description>
    The secret password. Never share these.
    </description>
  </property>
  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>abfs://${storage_container}@${storage_account_url}.dfs.core.windows.net/</value>
    <description>location of default database for the warehouse</description>
</property>
</configuration>
