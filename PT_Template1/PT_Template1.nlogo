; DA382A_Project_VT24
; template for the programming task with cops and citizen agents
;
; See the description in the file README on GitHub on how to work with the project files
;
;
;




; ************ INCLUDED FILES *****************
__includes [
    "setupenvironment.nls" ; setup-functions for setting up the environment with houses town-square, work-places, prison, police-station, restaurants, ....
    "citizens.nls" ; code for citizen agents
    "cops.nls"; code for cop agents
    "bdi.nls" ; contains the extension code for bdi with beliefs hash-tables and intention stacks
    "communication.nls"; contains the extension for FIPA-like communication protocols
    "time_library.nls"; code for the time extension library
    "vid.nls" ; contains the code for the recorder. You also need to activate the vid-extension and the command at the end of setup
]
; ********************end included files ********

; ************ EXTENSIONS *****************
extensions [
   matrix
 vid bitmap; used for recording of the simulation
]
; ********************end extensions ********

;****************** INITIAL AND DEFINITIONS PART **********
;
;----- Breeds of agents
breed [citizens citizen]  ;
breed [cops cop] ;

globals [
  ;
  town-square-matrix
  
  ; Global variables used by the citizen agents to adapt their local variables
  L;------------------------current global government legitimacy
  newArrests;---------------number of newly arrested citizens during the time interval
  alfa;---------------------constant factor that determines how fast arresting episodes are forgotten
  glbFear;------------------value for the collective global fear amongst citizen agents
  nArrests;-----------------Total number of currently arrested citizens
  Jmax;---------------------Maximum jail term that a citizen can be sentenced to


  ; Global variables for the Observer to monitor the dynamics and the result of the simulation
  max-jailterm
  numPrisoners ; Number of prisoners


  ;----- Time variables
  ; we might instead want to make use of the time extension, see https://ccl.northwestern.edu/netlogo/docs/time.html
  time; One tick represents x minutes, time contains the sum of minutes for a day
  flagMorning ; true if it is morning, e.g. time to get up
  flagAfternoon;
  flagEvening ; true if it is evening
  flagWeekend ; true if it is a weekend (2-days, Saturday and Sunday)
  tick-datetime
  sim-time               ; The current simulation time
  sim-start-time
  start-time
  time-simulated   ; Text string showing how much time has been simulated, with the units specified on the Interface
  sim-start-logotime

  timeTaker-stop-time



  ;----- Spatial units, locations
  locPrison ; location of the prison
  locPolStation; location of the police station
  locFactory; location of the factory
  locUni; location of the university
  locWork; location of the work-place
  locTownSquare; location of the town square
  locCinema; location of the entertainment-place
  locRestaurant; location of the restaurant
  locSocialEvents; location of the volunteer place
  numFreeCitizens
  newarrest

]

;---- General agent variables
turtles-own [
  ;speed
  beliefs
  intentions
  incoming-queue
]

;---- Specific, local variables of patches
patches-own [
  neighborhood        ; surrounding patches within the vision radius
  region              ; used for identification of different regions
]




; ######################## SETUP PART ################################
; setup of the environment, and the different agents
to setup
  clear-all
  ; define global variables that are not set as sliders
  set max-jailterm 10

  ; initialize general global variables (could also be moved to setup-environment)
  set numFreeCitizens 0
  set numPrisoners 0
  set newarrest 0
  set town-square-matrix matrix:make-constant 3 3 0
  ; setup of the environment:
  setup-environment ;
  ; setup of all patches

  ; setup citizens
  setup-citizens

  ; setup cops
  setup-cops

  ; time section
  initTime ; initialize the time and clock variables






  ; must be last in the setup-part:
  reset-ticks
  ;recorder
  if vid:recorder-status = "recording" [
    if Source = "Only View" [vid:record-view] ; records the plane
    if Source = "With Interface" [vid:record-interface] ; records the interface
  ]

end

; **************************end setup part *******



; ########################## TO GO/ STARTING PART ########################
;;
to go

  ;---- Time updates
  ;
  tick ;- update time
  update-time-flags ;- update time

  ;UPDATES THE VALUE OF TIME-SIMULATED FOR DISPLAY PURPOSE
  set time-simulated (word (time:difference-between sim-start-time sim-time "minute") " minutes")

  timeWrapAround


  ;---- Update of Global Variables
  ; update of global variables like for example fear, frustration and legitimation
  ;
  ; if dailyFlag [
  set L (1 / (exp((newarrest / num-citizens))))
  count-new-arrests
  ;    set dailyFlag false
   ; ]

  ; update for the observer functions like changes in number of arrests
  ;


  ;---- Agents to-go part -------------
  ; Cyclic execution of what the agents are supposed to do
  ;
  ask turtles [
    ; based on the type of agent
    if (breed = citizens) [
      citizen_behavior ; code as defined in the include-file "citizens.nls
      ]
    if (breed = cops) [
      cop_behavior ; code as defined in the include-file "cops.nls"
      ]

  ]






  ;recorder
 if vid:recorder-status = "recording" [
    if Source = "Only View" [vid:record-view] ; records the plane
    if Source = "With Interface" [vid:record-interface] ; records the interface
  ]

end ; - to go part



; ####################### OBSERVER FUNCTIONS ##############################
; monitoring functions with plots for number of arrested citizens


;-----------------------

to-report count-free-citizens
  report count citizens with [not inPrison?]
end

to count-new-arrests
  let new-arrest (citizens with [(color = red) and inPrison?])
  set newarrest count new-arrest
end
