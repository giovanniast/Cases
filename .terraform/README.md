## Componentes Principais da Arquitetura
*AWS ECS Fargate:* ECS Fargate para orquestração de containers sem gerenciar servidores diretamente.

*Amazon RDS (PostgreSQL):* Para o armazenamento de dados de carteira e transações dos usuários.Adicionalmente, a replicação read-only pode ser configurada para distribuir o tráfego de leitura e melhorar o desempenho.

*Amazon ElastiCache (Redis):* Cache distribuído em Redis para armazenar ordens pendentes e processar informações de compra e venda rapidamente.

*Amazon SQS:* Para garantir que as transações sejam processadas de maneira assíncrona e com resiliência.