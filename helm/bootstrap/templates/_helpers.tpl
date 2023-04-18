{{- define "usertool.labExtraUrls" }}
{{- $domain := .Values.domain }}
{{- $consoleUrl := printf "https://console-openshift-console.%s;OpenShift Console" $domain }}
{{- $kialiUrl := printf "https://kiali-%%USERNAME%%-dev-istio-system.%s;Kiali" $domain }}
{{- $urls := list $consoleUrl $kialiUrl }}
{{- join "," $urls }}
{{- end }}

{{- define "usertool.labModuleUrls" }}
{{- $domain := .Values.domain }}
{{- $params := printf "?USERID=%%USERNAME%%&SUBDOMAIN=%s" $domain }}
{{- $module1 := printf "https://guides-guides.%s/summit-ossm-labs-guides/main/m1/intro.html%s;Scenario 1" $domain $params }}
{{- $module2 := printf "https://guides-guides.%s/summit-ossm-labs-guides/main/m2/intro.html%s;Scenario 2" $domain $params }}
{{- $module3 := printf "https://guides-guides.%s/summit-ossm-labs-guides/main/m3/intro.html%s;Scenario 3" $domain $params }}
{{- $urls := list $module1 $module2 $module3 }}
{{- join "," $urls }}
{{- end }}
