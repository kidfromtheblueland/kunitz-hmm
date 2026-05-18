import sys
import numpy as np


def get_data(file_name):
    preds = []
    skipped = 0
    with open(file_name, 'r') as fh:
        for line_num, line in enumerate(fh, 1):
            line = line.strip()
            if not line:
                continue
            v = line.split()
            try:
                e_value = float(v[1])
                real_class = int(v[2])
                preds.append((e_value, real_class))
            except (IndexError, ValueError):
                skipped += 1
                if skipped <= 5:
                    print("Warning: Skipping bad line {}: {}".format(line_num, line))

    print("Successfully loaded {} predictions.".format(len(preds)))
    if skipped > 0:
        print("Skipped {} bad lines.".format(skipped))
    return preds


def get_confusion_matrix(preds, threshold):
    cm = np.zeros((2, 2), dtype=int)
    for e_value, real_class in preds:
        pred_class = 1 if e_value <= threshold else 0
        cm[real_class, pred_class] += 1
    return cm


def get_performance(cm):
    tn = cm[0, 0]
    fp = cm[0, 1]
    fn = cm[1, 0]
    tp = cm[1, 1]

    total = np.sum(cm)
    accuracy = (tp + tn) / total if total > 0 else 0.0

    precision = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0.0          # Sensitivity
    specificity = tn / (tn + fp) if (tn + fp) > 0 else 0.0

    # F1 Score
    if precision + recall > 0:
        f1 = 2 * (precision * recall) / (precision + recall)
    else:
        f1 = 0.0

    # Matthews Correlation Coefficient (MCC)
    numerator = (tp * tn) - (fp * fn)
    denominator = np.sqrt((tp + fp) * (tp + fn) * (tn + fp) * (tn + fn))
    mcc = numerator / denominator if denominator != 0 else 0.0

    return accuracy, precision, recall, specificity, f1, mcc


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 performance.py <file> <threshold>")
        sys.exit(1)

    file_name = sys.argv[1]
    threshold = float(sys.argv[2])

    data = get_data(file_name)
    matrix = get_confusion_matrix(data, threshold)
    acc, prec, rec, spec, f1, mcc = get_performance(matrix)

    print(f"\nThreshold : {threshold}")
    print("Confusion Matrix (Real → Predicted):")
    print("          Pred Neg   Pred Pos")
    print("Real Neg ", matrix[0])
    print("Real Pos ", matrix[1])
    print("\nMetrics:")
    print(f"Accuracy    : {acc:.4f}")
    print(f"Precision   : {prec:.4f}")
    print(f"Recall (Sn) : {rec:.4f}")
    print(f"Specificity : {spec:.4f}")
    print(f"F1 Score    : {f1:.4f}")
    print(f"MCC         : {mcc:.4f}")

