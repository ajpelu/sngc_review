### Create a csv with the potential mail list

We compiled a mail list from several sources: \* Dossier \* Literature Review Search (WOS) \* Sierra Nevada LTER Research community

#### Dossier

A sql query to db `dossier_filiaciones` was done

``` sql
SELECT 
  dicc_autores.email
FROM 
  public.dicc_autores;
```

Save as: `/data/mail_raw/dossier_filiaciones.csv`

#### Sierra Nevada LTER Research community

Several sql queries from db `nodo_lter_sn`

`sql`sql SELECT "Investigadores\_solicitudes".email FROM public."Investigadores\_solicitudes" WHERE "Investigadores\_solicitudes".email IS NOT NULL AND "Investigadores\_solicitudes".email &lt;&gt; ''; \`\`\`

Save as: `/data/mail_raw/investigadores_solicitudes.csv`
