import Mathlib

/-! Basic theory of probability spaces. -/

open MeasureTheory

/-- A ProbSpace is a MeasureSpace in which the canonical volume measure is also a probability measure. -/
class ProbSpace (Ω : Type*) extends MeasureSpace Ω, IsProbabilityMeasure volume


/-- The probability measure associated to a ProbSpace --/
@[simps (config := .lemmasOnly)]
def probMeasure (Ω : Type*) [ProbSpace Ω] : ProbabilityMeasure Ω := ⟨volume, inferInstance⟩

def Probspace.measure (Ω : Type*) [ProbSpace Ω] : Measure Ω := volume

/-- prob Ω E is the probability of E in Ω. -/
def prob {Ω : Type*} [ProbSpace Ω] (E : Set Ω) := probMeasure Ω E

/-- The customary notation for probability.  Todo: integrate this with https://leanprover-community.github.io/mathlib4_docs/Mathlib/Probability/Notation.html -/
notation:100 "P[ " E " ]" => prob E

/-- Total event has probability one. -/
lemma prob_univ (Ω : Type*) [ProbSpace Ω] : P[(⊤ : Set Ω)] = 1 := (probMeasure Ω).coeFn_univ

/-- Larger events have larger probability. -/
lemma prob_mono {Ω : Type*} [ProbSpace Ω] {A B : Set Ω} (h : A ≤ B) : P[A] ≤ P[B] :=
  (probMeasure Ω).apply_mono h

/-- All events have probability at most 1.  Measurability not required! -/
lemma prob_le_one [ProbSpace Ω] (E : Set Ω) : P[ E ] ≤ 1 := (probMeasure Ω).apply_le_one E

/- an alternate proof:

lemma prob_le_one' [ProbSpace Ω] (E : Set Ω) : P[ E ] ≤ 1 := by
  rw [← prob_univ Ω]
  simp [prob_mono]

-/

/-- Probability can be computed using probMeasure. --/
lemma prob_eq [ProbSpace Ω] (E : Set Ω) : P[ E ] = probMeasure Ω E := rfl

/-- Probability can be computed using measure (after coercion to ENNReal). --/
lemma prob_eq' [ProbSpace Ω] (E : Set Ω) : P[ E ] = Probspace.measure Ω E := by
   unfold prob probMeasure Probspace.measure
   simp
   congr

/-- Give all finite types the discrete sigma-algebra by default. -/
instance Fintype.instMeasurableSpace [Fintype S] : MeasurableSpace S := ⊤

open BigOperators

/-- The probability densities of a random variable sum to 1. Proof is way too long.  TODO: connect this with Mathlib.Probability.ProbabilityMassFunction.Basic -/
lemma totalProb {Ω : Type*} [ProbSpace Ω] [Fintype S] {X : Ω → S} (hX: Measurable X): ∑ s : S, P[ X ⁻¹' {s} ] = 1 := by
  rw [<-ENNReal.coe_eq_coe]
  push_cast
  conv =>
    lhs; congr; rfl; intro s
    rw [prob_eq']
  rw [<- MeasureTheory.measure_biUnion_finset]
  . rw [<-prob_eq']
    norm_cast
    convert prob_univ Ω
    ext _
    simp
  . dsimp [Set.PairwiseDisjoint, Set.Pairwise,Function.onFun]
    intro x _ y _ hxy
    rw [disjoint_iff]
    contrapose! hxy
    simp at hxy
    have : (X ⁻¹' {x} ∩ X ⁻¹' {y} ).Nonempty := by
      exact Set.nmem_singleton_empty.mp hxy
    rcases this with ⟨ a, ha ⟩
    simp at ha
    rw [<-ha.1, <-ha.2]
  intro s _
  exact hX trivial
