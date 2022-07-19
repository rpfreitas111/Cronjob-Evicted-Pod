# Cronjob-Evicted-Pod
Este cronjob tem a finalidade de rodar limpar o cluster kubernetes eliminando pod com erros Evicted na situação de Error, ContainerStatusUnknown ou Completed. Além do cronjob remover os pod também é realizado um report para algum canal utilizando de webhook como discord ou slack.

## Informação que deve ser alterada para funcionar.
- Inserir-a-url-do-webhook-do-discord-ou-slack => alterar este texto pela url do webhook.
