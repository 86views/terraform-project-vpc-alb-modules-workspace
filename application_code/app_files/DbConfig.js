const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");

const secret_name = process.env.SECRET_NAME;
const region = process.env.REGION;

async function getDbSecret() {
    console.log(`[DbConfig] Fetching secret: ${secret_name} in region: ${region}`);
    const client = new SecretsManagerClient({ region: region });
    let response;

    try {
        response = await client.send(
            new GetSecretValueCommand({
                SecretId: secret_name,
                VersionStage: "AWSCurrent",
            })
        );
    } catch (error) {
        throw error;
    }

    const secret = JSON.parse(response.SecretString);

    return {
        DB_HOST: secret.endpoint,
        DB_USER: secret.username,
        DB_PWD: secret.password,
        DB_DATABASE: secret.db_name || 'webappdb'
    };
}

module.exports = { getDbSecret };