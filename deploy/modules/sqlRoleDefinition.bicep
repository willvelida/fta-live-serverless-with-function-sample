param cosmosDbAccountName string
param dataActions array
param cosmosDbId string
param functionAppPrincipalId string
param roleDefinitionName string

var roleDefinitionId = guid('sql-role-definition-', functionAppPrincipalId, cosmosDbId)
var roleAssignmentId = guid(roleDefinitionId, functionAppPrincipalId, cosmosDbId)

resource sqlRoleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-11-15-preview' = {
  name: '${cosmosDbAccountName}/${roleDefinitionId}'
  properties: {
    roleName: roleDefinitionName
    type: 'CustomRole'
    assignableScopes: [
      cosmosDbId
    ]
    permissions: [
      {
        dataActions: dataActions
      }
    ]
  }
}

resource sqlRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-11-15-preview' = {
  name: '${cosmosDbAccountName}/${roleAssignmentId}'
  properties: {
    roleDefinitionId: sqlRoleDefinition.id
    principalId: functionAppPrincipalId
    scope: cosmosDbId
  }
}
