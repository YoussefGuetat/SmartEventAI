const express = require('express');
const axios = require('axios');
const {Eureka} = require('eureka-js-client');
const app = express();
app.use(express.json());

const EVENT_SERVICE_BASE_URL = 'http://localhost:8080/events';
const AI_SERVICE_URL = 'http://localhost:8080/ai/generate-event-content'

app.post('/workflow/start/:eventId', async (req, res) => {
    const eventId  = req.params.eventId;
    
    try{
        // Récupérer l'evenement
        const eventResponse = await axios.get
        (`${EVENT_SERVICE_BASE_URL}/getEvenementById/${eventId}`);
    
        const event = eventResponse.data;
        console.log("Evenement récupéré:", event);

        // Appel a l'ia pour généré du contenu
        const aiRequestBody = {
            title: event.titleEvenement,
            date: event.dateEvenement,
            location: event.location,
            description: event.descriptionEvenement
        };
        console.log("Corps de la requête AI:", aiRequestBody);

        const aiResponse = await axios.post(AI_SERVICE_URL, aiRequestBody);
        const aiContent = aiResponse.data;
        console.log("Contenu généré par l'IA:", aiContent);

        // Mettre à jour l'evenement avec le contenu généré
        const updatedEvent = {
            ...event,
            titleEvenement: aiContent.title || event.titleEvenement,
            descriptionEvenement: aiContent.description || event.descriptionEvenement,
            agenda: aiContent.agenda || event.agenda,
            statusEvenement: 'GENERATED'
        };

        const updateResponse = await axios.put
        (`${EVENT_SERVICE_BASE_URL}/updateEvenement`, updatedEvent);

        console.log("Evenement mis à jour:", updateResponse.data);

        return res.status(200).json({
            message: 'Workflow IA exécuté avec succès',
            eventId,
            status: 'GENERATED',
            updatedEvent: updateResponse.data
        });
    }
    catch (error) {
        console.error('Erreur dans le workflow : ', error.message);
    }
});

app.get('/workflow/status/:eventId', async (req, res) => {
    const eventId  = req.params.eventId;
    try {
        const eventResponse = await axios.get
        (`${EVENT_SERVICE_BASE_URL}/getEvenementById/${eventId}`);
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

const PORT = 3000;
const eureka = new Eureka({
    instance: {
        app: 'workflow-service',
        instanceId: `workflow-service:${PORT}`,
        hostName: 'localhost',
        ipAddr: '127.0.0.1',
        statusPageUrl : `http://localhost:${PORT}/actuator/health`,
        port: {
            '$': PORT,
            '@enabled': 'true',
        },
        vipAddress: 'workflow-service',
        dataCenterInfo: {
            '@class': 'com.netflix.appinfo.InstanceInfo$DefaultDataCenterInfo',
            name: 'MyOwn',
        },
    },
    eureka: {
        host: 'localhost',
        port: 8761,
        servicePath: '/eureka/apps/'
    },
});

eureka.start(err => {
    if(err){
        console.error('Erreur lors de l\'enregistrement à Eureka : ', err);
    } else {
        console.log('Enregistré avec succès auprès de Eureka');
    }
});

app.listen(PORT, () => {
    console.log(`Workflow Service is running on port http://localhost:${PORT}`);
});