//utils.libsonnet
{
  labelselector(podantiaffinitytag, podantiaffinityns)::
  {
    labelSelector: {
      matchExpressions: [
        {
          key: "podantiaffinitytag",
          operator: "In",
          values: [podantiaffinitytag,],
        },
      ],
    },
    topologyKey: "kubernetes.io/hostname",
    namespaces: podantiaffinityns,
  },
}

{
  podantiaffinity(podantiaffinitytag, podantiaffinitytype, podantiaffinityns)::
  {
    podAntiAffinity: {
      [podantiaffinitytype]: if podantiaffinitytype == "preferredDuringSchedulingIgnoredDuringExecution" then
      [
        {
          weight: 1,
          podAffinityTerm: $.labelselector(podantiaffinitytag, podantiaffinityns),
        },
      ]
      else if podantiaffinitytype == "requiredDuringSchedulingIgnoredDuringExecution" then
      [
        $.labelselector(podantiaffinitytag, podantiaffinityns),
      ]
      else 
        error "not support podantiaffinity type",
    },
  },
}

{
  addcolonforport(port)::
  if port == "" then
    ""
  else 
    ":" + port
}