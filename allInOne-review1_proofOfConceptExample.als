open util/integer

abstract sig AssociatedElement { }

abstract sig Role {
	
}

abstract sig Position {
	participatesIn: set Role,
	isMemberOf: one OrganizationalUnit,
	canDelegateWorkTo: set Position,
	reportsTo: lone Position
}{
	reportsTo != this
}

abstract sig Person extends AssociatedElement {
	occupies: set Position,
	hasCapability: set Capability
}

abstract sig Capability {

}

abstract sig OrganizationalUnit {

}


abstract sig PEvent { pos: disj Int }
abstract sig TaskEvent extends PEvent{
    assoEl: some AssociatedElement
}{ #(Task & assoEl) = 1 }
sig HumanTaskEvent extends TaskEvent {}{
   #(Person & assoEl) = 1
}

abstract sig Task extends AssociatedElement{}

// Facts/Invariants: 
// >> Trace structure, non-structural constraints
fact{
    one te: TaskEvent | te.pos = integer/min
    all te: TaskEvent | te.pos = integer/min or sub[te.pos,1] in TaskEvent.pos 
}

// Utility Functions
fun any(asso: AssociatedElement) : set TaskEvent {
    { hte: TaskEvent | asso in hte.assoEl }
}
fun inBefore(currentEvent: TaskEvent, asso: AssociatedElement) : set TaskEvent {
    { hte: TaskEvent | hte.pos < currentEvent.pos and asso in hte.assoEl }
}
fun inAfter(currentEvent: TaskEvent, asso: AssociatedElement) : set TaskEvent {
    { hte: TaskEvent | hte.pos > currentEvent.pos and asso in hte.assoEl }
}
fun inBetween(searchStart, searchEnd: TaskEvent, asso: AssociatedElement) : set TaskEvent {
    { hte: TaskEvent | hte.pos > searchStart.pos and hte.pos < searchEnd.pos and asso in hte.assoEl }
}
fun atPos(asso: AssociatedElement, givenPos: Int) : set TaskEvent {
    { hte: TaskEvent | hte.pos = int[givenPos] and asso in hte.assoEl }
}

// MP-Declare Templates
pred existence[t: Task, act: TaskEvent] {
  	#(any[t] & act) > 0
}
pred respondedExistence[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t1] & act | #(inAfter[hte,t2] & tar & cor.hte) > 0 || #(inBefore[hte,t2] & tar & cor.hte) > 0
}
pred response[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent]{	
  	all hte: (any[t1] & act) | #(inAfter[hte, t2] & cor.hte & tar) > 0
}
pred alternateResponse[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte1, hte2: any[t1] & act | (hte2.pos > hte1.pos) implies #(inBetween[hte1, hte2, t2] & tar & cor.hte2) > 0 and response[t1, t2, act, tar, cor]
}
pred chainResponse[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t1] & act | #(atPos[t2, add[hte.pos, 1]] & tar & cor.hte) > 0
}
pred precedence[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t2] & act | #(inBefore[hte, t1] & tar & cor.hte) > 0
}
pred alternatePrecedence[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte1, hte2: any[t2] & act | (hte1.pos > hte2.pos) implies #(inBetween[hte2, hte1, t2] & tar & cor.hte1) > 0 and precedence[t1, t2, act, tar, cor]
}
pred chainPrecedence[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t2] & act | #(atPos[t1, sub[hte.pos, 1]] & tar & cor.hte) > 0
}
pred notRespondedExistence[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t1] & act | #(inAfter[hte, t2] & tar & cor.hte) = 0 && #(inBefore[hte, t2] & tar & cor.hte) = 0
}
pred notChainResponse[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t1] & act | #(atPos[t2, add[hte.pos, 1]] & tar & cor.hte) = 0
}
pred notChainPresedence[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
		all hte: any[t2] & act | #(atPos[t1, sub[hte.pos, 1]] & tar & cor.hte) = 0
}
pred notResponse[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t1] & act | #(inAfter[hte, t2] & tar & cor.hte) = 0
}
pred notPresedence[t1, t2: Task, act, tar: TaskEvent, cor: TaskEvent -> TaskEvent] {
	all hte: any[t2] & act | #(inBefore[hte, t1] & tar & cor.hte) = 0
}


// RALph rule templates
pred directAssignment(t: Task, p: Person) {
  all e: HumanTaskEvent | #(t & e.assoEl) > 0 implies #(p & e.assoEl) > 0
}

pred roleBasedAssignment(t: Task, r: Role) {
  all e: HumanTaskEvent | #(t & e.assoEl) > 0 implies #((e.assoEl & Person).occupies.participatesIn & r) > 0
}

pred posBasedAssignment(t: Task, p: Position) {
  all e: HumanTaskEvent | #(t & e.assoEl) > 0 implies #((e.assoEl & Person).occupies & p) > 0
}

pred capBasedAssignment(t: Task, c: Capability) {
  all e: HumanTaskEvent | #(t & e.assoEl) > 0 implies #((e.assoEl & Person).hasCapability & c) > 0
}

pred unitBasedAssignment(t: Task, u: OrganizationalUnit) {
  all e: HumanTaskEvent | #(t & e.assoEl) > 0 implies #((e.assoEl & Person).occupies.isMemberOf & u) > 0
}

pred negUnitBasedAssignment(t: Task, u: OrganizationalUnit) {
  all e: HumanTaskEvent | #(t & e.assoEl) > 0 implies #((e.assoEl & Person).occupies.isMemberOf & u) = 0
}

pred bindingOfDuties(t1, t2: Task) {
  all e1,e2: HumanTaskEvent | #(t1 & e1.assoEl) > 0 and #(t2 & e2.assoEl) > 0 implies #(e1.assoEl & e2.assoEl & Person) > 0
}

pred separationOfDuties(t1, t2: Task) {
  all e1,e2: HumanTaskEvent | #(t1 & e1.assoEl) > 0 and #(t2 & e2.assoEl) > 0 implies #(e1.assoEl & e2.assoEl & Person) = 0
}

pred hierarchyBasedAssignmentDelegate(t: Task, p: Position) {
  all e: HumanTaskEvent | #(e.assoEl & t) > 0 implies #((e.assoEl & Person).occupies.canDelegateWorkTo & p)  > 0
}

pred hierarchyBasedAssignmentReport(t: Task, p: Position) {
  all e: HumanTaskEvent | #(e.assoEl & t) > 0 implies #((e.assoEl & Person).occupies.reportsTo & p)  > 0
}

pred caseHandling(p: Person) {
	all e: HumanTaskEvent | (e.assoEl & Person) = p
}

// Analysis operations
// Potential participants
pred PP(t: Task) {
	all e: HumanTaskEvent | #(e.assoEl & t) > 0 implies #(Person & e.assoEl) = 0
}

// Potential activities
pred PA(p: Person) {
	all e: HumanTaskEvent | #(e.assoEl & Task) > 0 implies #(p & e.assoEl) = 0
}

// Non-Potential participants
pred NPP(t: Task) {
	// the relative complement of the set of all resources and the result of PP
}

// Non-potential activities
pred NPA(p: Person) {
	// the relative complement of the set of all activities and the result of PA
}

// Critical Participants
pred CP() {
	all p: Person | p in HumanTaskEvent.assoEl
}

// Critical activities
pred CAhelper(t: Task, p: Person) {
	all e: HumanTaskEvent | #(e.assoEl & t) > 0 implies #(p & e.assoEl) = 1
}

pred CA(p: Person) {
	no t: (HumanTaskEvent.assoEl & Task) | CAhelper[t, p]
}

// Is p in PP (pPP)
pred pPP(p: Person, t: Task) {
	no e: HumanTaskEvent | #(e.assoEl & t) > 0 and #(p & e.assoEl) = 1
}

// Is a specific role/position/capability required for the execution of the process?
pred RPC(rpc: (Position + Role + Capability)) {
	rpc in ((HumanTaskEvent.assoEl & Person).occupies + (HumanTaskEvent.assoEl & Person).hasCapability + (HumanTaskEvent.assoEl & Person).occupies.participatesIn)
}

// Which roles are not involved in the process?
pred NP {
	all po: Position | not RPC[po] 
}

// The process model
one sig ApplyForTrip extends Task{}
one sig ApproveApplication extends Task{}
one sig CheckApplication extends Task{}
one sig EditResponse extends Task{}
one sig BookAccommodation extends Task{}
one sig BookFlight extends Task{}
one sig BuyTransportTickets extends Task{}
one sig ArchiveTripDocuments extends Task{}

one sig Admin1 extends Person{}{ occupies = AdminPosition  }
one sig Admin2 extends Person{}{ occupies = AdminPosition }
one sig Secretary1 extends Person{}{ occupies = Secretary }
one sig Secretary2 extends Person{}{ occupies = Secretary }
one sig Researcher1 extends Person{}{ occupies = Researcher }
one sig Researcher2 extends Person{}{ occupies = Researcher }
one sig Researcher3 extends Person{}{ occupies = Researcher }
one sig Researcher4 extends Person{}{ occupies = Researcher }
one sig Researcher5 extends Person{}{ occupies = Researcher }
one sig Researcher6 extends Person{}{ occupies = Researcher }
one sig SJ extends Person{}{ occupies = Professor }

one sig Researcher extends Position{}{ 
	#participatesIn = 0
	isMemberOf = ResearchGroup 
	#canDelegateWorkTo = 0
	#reportsTo = 0
}
one sig Secretary extends Position{}{ 
	#participatesIn = 0
	isMemberOf = ResearchGroup 
	#canDelegateWorkTo = 0
	#reportsTo = 0
}
one sig Professor extends Position{}{ 
	#participatesIn = 0
	isMemberOf = ResearchGroup 
	canDelegateWorkTo = Researcher
	#reportsTo = 0
}

one sig AdminPosition extends Position{}{
	#participatesIn = 0
	isMemberOf = Administration 
	#canDelegateWorkTo = 0
	#reportsTo = 0
}

one sig Administration extends OrganizationalUnit{}
one sig ResearchGroup extends OrganizationalUnit{}

fact {
	// OrgMM avoid random values
	all p: Position | #(p.reportsTo) = 0  and #(p.participatesIn) = 0
	
	// Control Flow
	#(atPos[ApplyForTrip, add[integer/min,0]]) > 0
	#(atPos[ApproveApplication, add[integer/min,1]]) > 0	
	#(atPos[CheckApplication, add[integer/min,2]]) > 0
	#(atPos[EditResponse, add[integer/min,3]]) > 0
	response[EditResponse, BookAccommodation, TaskEvent, TaskEvent, TaskEvent -> TaskEvent]
	response[EditResponse, BookFlight, TaskEvent, TaskEvent, TaskEvent -> TaskEvent]
	response[EditResponse, BuyTransportTickets, TaskEvent, TaskEvent, TaskEvent -> TaskEvent]
	precedence[BookAccommodation, ArchiveTripDocuments,TaskEvent, TaskEvent, TaskEvent -> TaskEvent]
	precedence[BookFlight, ArchiveTripDocuments,TaskEvent, TaskEvent, TaskEvent -> TaskEvent]
	precedence[BuyTransportTickets, ArchiveTripDocuments, TaskEvent, TaskEvent, TaskEvent -> TaskEvent]
	response[BookAccommodation, ArchiveTripDocuments, TaskEvent, TaskEvent, TaskEvent -> TaskEvent]

	// Each Task only once 
	all te1,te2: TaskEvent | #(te1.assoEl & Task & te2.assoEl) > 0 implies te1 = te2

	// Resource assignment rules
	bindingOfDuties[ApplyForTrip,BookFlight]	
	bindingOfDuties[ApplyForTrip,BookAccommodation]
	bindingOfDuties[ApplyForTrip,BuyTransportTickets]
	bindingOfDuties[BookAccommodation,BookFlight]
	bindingOfDuties[BookAccommodation,BuyTransportTickets]
	bindingOfDuties[BookFlight,BuyTransportTickets]
	posBasedAssignment[ApplyForTrip,Researcher]
	posBasedAssignment[EditResponse,Secretary]
	posBasedAssignment[ArchiveTripDocuments,Secretary]
	directAssignment[ApproveApplication,SJ]
	hierarchyBasedAssignmentDelegate[ApproveApplication, Researcher]
	unitBasedAssignment[CheckApplication, Administration]
		
}

fact {
		// Exemplary non-empty trace
		//#atPos[Researcher2,add[integer/min,0]]>0
}

assert testPP {
	PP[BookFlight]	
}


check testPP for 8 TaskEvent, 0 Role, 0 Capability, 2 OrganizationalUnit, 4 Position
