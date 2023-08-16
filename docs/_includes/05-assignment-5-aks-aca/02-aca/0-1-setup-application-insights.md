1. Create an Application Insights resource:

    ```bash
    az monitor app-insights component create --app appi-dapr-workshop-java --location eastus --kind web -g rg-dapr-workshop-java --application-type web
    ```

    You may receive a message to install the application-insights extension, if so please install the extension for this exercise.

1. Get the instrumentation key for the Application Insights and set it to the `INSTRUMENTATION_KEY` variable:

    - Linux/Unix shell:

      ```bash
      INSTRUMENTATION_KEY=$(az monitor app-insights component show --app appi-dapr-workshop-java -g rg-dapr-workshop-java --query instrumentationKey)
      echo $INSTRUMENTATION_KEY
      ```

    - PowerShell:

      ```powershell
      $INSTRUMENTATION_KEY = az monitor app-insights component show --app appi-dapr-workshop-java -g rg-dapr-workshop-java --query instrumentationKey
      $INSTRUMENTATION_KEY
      ```
