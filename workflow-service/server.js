const express = require('express');
const axios = require('axios');
const {Eureka} = require('eureka-js-client');
const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;
const SERVICE_HOSTNAME = process.env.SERVICE_HOSTNAME || 'localhost';
const EVENT_SERVICE_URL = process.env.EVENT_SERVICE_URL || 'http://localhost:8093';
const AI_SERVICE_URL = process.env.AI_SERVICE_URL || 'http://localhost:8000';

app.post('/workflow/start/:eventId', async (req, res) => {
    const eventId = req.params.eventId;
    
    try {
        const eventResponse = await axios.get(`${EVENT_SERVICE_URL}/evenement/getEvenementById/${eventId}`);
        const event = eventResponse.data;
        console.log("Evenement récupéré:", event);
        
        const aiRequestBody = {
            title: event.titleEvenement,
            date: event.dateEvenement,
            location: event.location,
            description: event.descriptionEvenement
        };
        console.log("Corps de la requête AI:", aiRequestBody);
        
        const aiResponse = await axios.post(`${AI_SERVICE_URL}/ai/generate-event-content`, aiRequestBody);
        const aiContent = aiResponse.data;
        console.log("Contenu généré par l'IA:", aiContent);
        
        const updatedEvent = {
            ...event,
            titleEvenement: aiContent.title || event.titleEvenement,
            descriptionEvenement: aiContent.description || event.descriptionEvenement,
            agenda: aiContent.agenda || event.agenda,
            statusEvenement: 'GENERATED'
        };
        
        const updateResponse = await axios.put(`${EVENT_SERVICE_URL}/evenement/updateEvenement`, updatedEvent);
        console.log("Evenement mis à jour:", updateResponse.data);
        
        return res.status(200).json({
            message: 'Workflow IA exécuté avec succès',
            eventId,
            status: 'GENERATED',
            updatedEvent: updateResponse.data
        });
    } catch (error) {
        console.error('Erreur dans le workflow : ', error.message);
        return res.status(500).json({ error: 'Erreur serveur', details: error.message });
    }
});

app.get('/workflow/status/:eventId', async (req, res) => {
    const eventId = req.params.eventId;
    try {
        const eventResponse = await axios.get(`${EVENT_SERVICE_URL}/evenement/getEvenementById/${eventId}`);
        const event = eventResponse.data;
        return res.status(200).json({
            eventId,
            status: event.statusEvenement
        });
    } catch (error) {
        console.error('Erreur lors de la récupération du statut : ', error.message);
        return res.status(500).json({ error: 'Erreur serveur' });
    }
});

app.get('/health', (req, res) => {
    res.status(200).json({ status: 'UP' });
});

// Configuration Eureka simplifiée
const eurekaClient = new Eureka({
    instance: {
        app: 'WORKFLOW-SERVICE',
        instanceId: `workflow-service-${SERVICE_HOSTNAME}-${PORT}`,
        hostName: SERVICE_HOSTNAME,
        ipAddr: SERVICE_HOSTNAME,
        statusPageUrl: `https://${SERVICE_HOSTNAME}/health`,
        healthCheckUrl: `https://${SERVICE_HOSTNAME}/health`,
        homePageUrl: `https://${SERVICE_HOSTNAME}/`,
        port: {
            '$': 443,
            '@enabled': true,
        },
        vipAddress: 'workflow-service',
        dataCenterInfo: {
            '@class': 'com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo',
            name: 'MyOwn',
        },
        registerWithEureka: true,
        fetchRegistry: true,
        leaseInfo: {
            renewalIntervalInSecs: 30,
            durationInSecs: 90,
        },
    },
    eureka: {
        host: 'eureka-server-production-9937.up.railway.app',
        port: 443,
        servicePath: '/eureka/apps/',
        maxRetries: 10,
        requestRetryDelay: 5000,
        heartbeatInterval: 30000,
        registryFetchInterval: 30000,
        fetchRegistry: false,
        filterUpInstances: true,
        ssl: true,
        useDns: false,
    },
    requestMiddleware: (requestOpts, done) => {
        requestOpts.protocol = 'https:';
        requestOpts.host = 'eureka-server-production-9937.up.railway.app';
        requestOpts.port = 8761;
        done(requestOpts);
    },
});

eurekaClient.start((error) => {
    if (error) {
        console.error('Erreur Eureka:', error);
    } else {
        console.log('✅ Enregistré avec succès auprès de Eureka');
    }
});

// Gérer l'arrêt propre
process.on('SIGTERM', () => {
    eurekaClient.stop(() => {
        process.exit(0);
    });
});

app.listen(PORT, () => {
    console.log(`🚀 Workflow Service running on port ${PORT}`);
});
