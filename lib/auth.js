const firebase = require("firebase/app");
require("firebase/auth");
require("firebase/database");

// Configurar la conexión a Firebase
const firebaseConfig = {
  apiKey: "TU_API_KEY",
  authDomain: "TU_AUTH_DOMAIN",
  databaseURL: "TU_DATABASE_URL",
  projectId: "TU_PROJECT_ID",
  storageBucket: "TU_STORAGE_BUCKET",
  messagingSenderId: "TU_MESSAGING_SENDER_ID",
  appId: "TU_APP_ID"
};

firebase.initializeApp(firebaseConfig);

// Crear una referencia a la base de datos de Firebase
const database = firebase.database();

// Función para registrar un nuevo usuario con el nodo "Paciente"
function registrarPaciente(email, password, nombre, apellido) {
  return firebase.auth().createUserWithEmailAndPassword(email, password)
    .then((userCredential) => {
      // Agregar el usuario a la base de datos con el nodo "Paciente"
      const userId = userCredential.user.uid;
      return database.ref(`pacientes/${userId}`).set({
        nombre: nombre,
        apellido: apellido
      });
    })
    .catch((error) => {
      console.error("Error al registrar paciente:", error);
      throw error;
    });
}

// Función para registrar un nuevo usuario con el nodo "Enfermera"
function registrarEnfermera(email, password, nombre, apellido) {
  return firebase.auth().createUserWithEmailAndPassword(email, password)
    .then((userCredential) => {
      // Agregar el usuario a la base de datos con el nodo "Enfermera"
      const userId = userCredential.user.uid;
      return database.ref(`enfermeras/${userId}`).set({
        nombre: nombre,
        apellido: apellido
      });
    })
    .catch((error) => {
      console.error("Error al registrar enfermera:", error);
      throw error;
    });
}

// Función para iniciar sesión con un usuario existente
function iniciarSesion(email, password) {
  return firebase.auth().signInWithEmailAndPassword(email, password)
    .catch((error) => {
      console.error("Error al iniciar sesión:", error);
      throw error;
    });
}