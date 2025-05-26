;; Health Outcome Contract
;; Tracks nutritional intervention results

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u500))
(define-constant err-not-found (err u501))
(define-constant err-unauthorized (err u502))

;; Health metrics structure
(define-map health-metrics
  { patient-id: uint, measurement-date: uint }
  {
    weight-kg: uint,
    bmi: uint,
    blood-glucose: uint,
    cholesterol-total: uint,
    blood-pressure-systolic: uint,
    blood-pressure-diastolic: uint,
    measured-by: principal,
    verified: bool
  }
)

;; Outcome assessments
(define-map outcome-assessments
  { patient-id: uint, assessment-id: uint }
  {
    start-date: uint,
    end-date: uint,
    intervention-type: (string-ascii 100),
    primary-outcome: (string-ascii 200),
    secondary-outcomes: (string-ascii 300),
    success-score: uint,
    assessor-id: principal
  }
)

;; Assessment counter
(define-data-var assessment-counter uint u0)

;; Authorized healthcare providers
(define-map authorized-providers principal bool)

;; Record health metrics
(define-public (record-health-metrics
  (patient-id uint)
  (measurement-date uint)
  (weight-kg uint)
  (bmi uint)
  (blood-glucose uint)
  (cholesterol-total uint)
  (blood-pressure-systolic uint)
  (blood-pressure-diastolic uint)
)
  (begin
    (asserts! (default-to false (map-get? authorized-providers tx-sender)) err-unauthorized)
    (map-set health-metrics
      { patient-id: patient-id, measurement-date: measurement-date }
      {
        weight-kg: weight-kg,
        bmi: bmi,
        blood-glucose: blood-glucose,
        cholesterol-total: cholesterol-total,
        blood-pressure-systolic: blood-pressure-systolic,
        blood-pressure-diastolic: blood-pressure-diastolic,
        measured-by: tx-sender,
        verified: true
      }
    )
    (ok true)
  )
)

;; Create outcome assessment
(define-public (create-outcome-assessment
  (patient-id uint)
  (start-date uint)
  (end-date uint)
  (intervention-type (string-ascii 100))
  (primary-outcome (string-ascii 200))
  (secondary-outcomes (string-ascii 300))
  (success-score uint)
)
  (let
    (
      (assessment-id (+ (var-get assessment-counter) u1))
    )
    (asserts! (default-to false (map-get? authorized-providers tx-sender)) err-unauthorized)
    (asserts! (<= success-score u100) err-unauthorized)
    (map-set outcome-assessments
      { patient-id: patient-id, assessment-id: assessment-id }
      {
        start-date: start-date,
        end-date: end-date,
        intervention-type: intervention-type,
        primary-outcome: primary-outcome,
        secondary-outcomes: secondary-outcomes,
        success-score: success-score,
        assessor-id: tx-sender
      }
    )
    (var-set assessment-counter assessment-id)
    (ok assessment-id)
  )
)

;; Add authorized provider (owner only)
(define-public (add-provider (provider principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set authorized-providers provider true)
    (ok true)
  )
)

;; Get health metrics
(define-read-only (get-health-metrics (patient-id uint) (measurement-date uint))
  (map-get? health-metrics { patient-id: patient-id, measurement-date: measurement-date })
)

;; Get outcome assessment
(define-read-only (get-outcome-assessment (patient-id uint) (assessment-id uint))
  (map-get? outcome-assessments { patient-id: patient-id, assessment-id: assessment-id })
)

;; Calculate improvement score (simplified)
(define-read-only (calculate-improvement (patient-id uint))
  ;; Simplified calculation - in reality would compare metrics over time
  u85
)
