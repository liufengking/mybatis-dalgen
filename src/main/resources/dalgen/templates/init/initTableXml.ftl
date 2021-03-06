<@pp.dropOutputFile />
<#import "../lib/lib.ftl" as lib/>
<#list dalgen.tables as table>
<@pp.changeOutputFile name = "/${dalgen.tablesPath}/${table.sqlName}.xml" />
<!DOCTYPE table SYSTEM "../config/table-config-1.0.dtd">
<table sqlname="${table.sqlName}" physicalName="${table.physicalName}"<#if table.remark??> remark="${table.remark!}"</#if>>
    <!--    &lt;&gt;   <> -->

    <operation name="insert" paramtype="object" remark="insert:${table.sqlName}">
        <#if dalgen.dbType=="MySQL">
        <selectKey resultType="java.lang.Long" keyProperty="id" order="AFTER">
            SELECT
            LAST_INSERT_ID()
        </selectKey>
        </#if>
        INSERT INTO ${table.sqlName}(
        <#list table.columnList as column>
            <#if column_index gt 0>,</#if>${column.sqlName}
        </#list>
        )VALUES(
        <#list table.columnList as column>
            <#if column_index gt 0>,</#if> ${lib.insertVal(column)}
        </#list>
        )
    </operation>

<#if table.primaryKeys??>
    <operation name="update" paramtype="object" remark="update table:${table.sqlName}">
        UPDATE ${table.sqlName}
        SET
        <#assign c_idx = 0>
        <#list table.columnList as column>
            <#if lib.updateIncludeColumn(column,table.primaryKeys.columnList)><#assign c_idx = c_idx+1>
            <#if c_idx gt 1>,</#if>${column.sqlName}${lib.space(column.sqlName)} = ${lib.updateVal(column)}
            </#if>
        </#list>
        WHERE
        <#list table.primaryKeys.columnList as column>
            <#if column_index gt 0>AND </#if>${column.sqlName}${lib.space(column.sqlName)} = ${"#"}{${column.javaName},jdbcType=${column.sqlType}}
        </#list>
    </operation>

    <operation name="deleteBy${table.primaryKeys.pkName}" multiplicity="one" remark="delete:${table.sqlName}">
        DELETE FROM
            ${table.sqlName}
        WHERE
        <#list table.primaryKeys.columnList as column>
            <#if column_index gt 0>AND </#if>${column.sqlName} = ${"#"}{${column.javaName},jdbcType=${column.sqlType}}
        </#list>
    </operation>

    <operation name="getBy${table.primaryKeys.pkName}" multiplicity="one" remark="get:${table.sqlName}">
        SELECT *
        FROM ${table.sqlName}
        WHERE
        <#list table.primaryKeys.columnList as column>
            <#if column_index gt 0>AND </#if>${column.sqlName} = ${"#"}{${column.javaName},jdbcType=${column.sqlType}}
        </#list>
    </operation>
</#if>
</table>
</#list>